--- rivnjannja – improved equation handling for LaTeX
--
-- Copyright: © 2024 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License: MIT

local pandoc = require 'pandoc'

--- Create a raw LaTeX element.
local function latex(tex)
  if type(tex) == 'table' then
    tex = table.concat(tex, '')
  end
  return pandoc.RawInline('latex', tex)
end

--- Create a filter with the given options.
local function make_filter (opts)

  --- Convert equation-wrapping spans to latex `equation` environments.
  local function eqspan_to_latex_equation (span)
    if not span.classes:includes 'equation' then
      return nil
    end

    local eq = span.content[1]
    if not eq or eq.t ~= 'Math' or eq.mathtype ~= 'DisplayMath' then
      return nil
    end

    local id = span.attr.identifier
    local label = id ~= '' and string.format('\\label{%s}', id) or nil
    return latex{
      '\\begin{equation}',
      label, '\n',
      eq.text,
      '\n\\end{equation}'
    }
  end

  --- Use `\eqref` to reference equations. Doesn't check if the
  -- linked object really is an equation.
  local function latex_links (link)
    if link.target:sub(1,4) == '#eq:' or
      link.attributes['ref-type'] == 'disp-formula' then
      return latex(string.format('\\eqref{%s}', link.target:sub(2)))
    end
  end

  return {
    Span = eqspan_to_latex_equation,
    Link = latex_links,
  }
end

local function filter_doc (doc)
  -- get options and unset the metadata field.
  local opts = doc.meta.rivnjannja or {}
  doc.meta.rivnjannja = nil

  return doc:walk(make_filter(opts))
end

return {
  {Pandoc = filter_doc}
}
