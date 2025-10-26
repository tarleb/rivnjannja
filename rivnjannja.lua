--- rivnjannja – improved equation handling for LaTeX
--
-- Copyright: © 2024 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License: MIT

local pandoc = require 'pandoc'
local utils  = require 'pandoc.utils'

local FORMAT = FORMAT or '<unknown>'

--
-- Helpers
--

--- Create a function that converts equation spans. The function
-- `format_handler` must take the math equation as it's first argument,
-- and the span attributes as the second argument. The function makes
-- sure that only equation spans are processed, other spans are ignored.
local function eqspan_to_format (format_handler)
  return function (span)
    local attr = span.attr
    if not attr.classes:includes 'equation' then
      return nil
    end

    local eq = span.content[1]
    if not eq or eq.t ~= 'Math' or eq.mathtype ~= 'DisplayMath' then
      return nil
    end

    return format_handler(eq, attr)
  end
end

--- Checks if a link appears to be pointing to an equation.
local function is_equation_link(link)
  return
    link.target:sub(1,4) == '#eq:' or
    link.attributes['ref-type'] == 'disp-formula'
end


--
-- LaTeX
--

--- Create a raw LaTeX element.
local function latex(tex)
  if type(tex) == 'table' then
    tex = table.concat(tex, '')
  end
  return pandoc.RawInline('latex', tex)
end

--- Create a filter with the given options.
local function make_latex_filter (opts)

  --- Convert equation-wrapping spans to latex `equation` environments.
  local eqspan_to_latex_equation = eqspan_to_format(
    function (eq, attr)
      local id = attr.identifier
      local label = id ~= '' and string.format('\\label{%s}', id) or nil
      return latex{
        '\\begin{equation}',
        label, '\n',
        eq.text,
        '\n\\end{equation}'
      }
    end
  )

  --- Use `\eqref` to reference equations. Doesn't check if the
  -- linked object really is an equation.
  local function latex_links (link)
    if is_equation_link(link) then
      return latex(string.format('\\eqref{%s}', link.target:sub(2)))
    end
  end

  return {
    Span = eqspan_to_latex_equation,
    Link = latex_links,
  }
end


--
-- Typst
--

--- Create a raw LaTeX element.
local function typst(typ)
  if type(typ) == 'table' then
    typ = table.concat(typ, '')
  end
  return pandoc.RawInline('typst', typ)
end

local typst_equation_numbering_header = typst[==[
// Number labeled equations
#set math.equation(numbering: "(1)")
#show math.equation: it => {
  if it.block and not it.has("label") [
    // "uncount" equations without labels
    #counter(math.equation).update(v => v - 1)
    // Empty label to avoid recursion
    #math.equation(it.body, block: true, numbering: none)#label("")
  ] else {
    it
  }
}
]==]

local function make_typst_filter (opts)

  --- Convert equation-wrapping spans to latex `equation` environments.
  local eqspan_to_typst_equation = eqspan_to_format(
    function (eq, attr)
      local id = attr.identifier
      local label = id ~= '' and string.format(' <%s>', id) or nil
      local tmpdoc = pandoc.Pandoc(pandoc.Plain{eq})
      return typst{pandoc.write(tmpdoc, 'typst'), label, '\n'}
    end
  )

  --- Use native crosslinking to reference equations.
  local function typst_equation_link (link)
    local target = link.target:sub(2)  -- remove leading hash sign
    if is_equation_link(link) then
      return typst(string.format('@%s[]', target))
    end
  end

  --- Enable equation labeling by Typst, but only for equations that
  --- have a label.
  local function enable_equation_labeling (meta)
    -- Ensure that header includes are a list
    local header_includes = utils.type(meta['header-includes']) == 'List'
      and meta['header-includes']
      or pandoc.List{meta['header-includes']}
    header_includes:insert(typst_equation_numbering_header)
    meta['header-includes'] = header_includes
    return meta
  end

  return {
    Meta = enable_equation_labeling,
    Span = eqspan_to_typst_equation,
    Link = typst_equation_link,
  }
end

--
-- Main
--

--- Convert equations to output-specific markup.
local function filter_doc (doc)
  -- get options and unset the metadata field.
  local opts = doc.meta.rivnjannja or {}
  doc.meta.rivnjannja = nil

  local filter = {}
  if FORMAT == 'latex' then
    filter = make_latex_filter(opts)
  elseif FORMAT == 'typst' then
    filter = make_typst_filter(opts)
  else
    pandoc.log.warn('Cannot handle equation number for format ' .. FORMAT)
  end

  return doc:walk(filter)
end

return {
  {Pandoc = filter_doc}
}
