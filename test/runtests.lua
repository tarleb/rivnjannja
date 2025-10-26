#!/usr/bin/env pandoc-lua
--- runtests.lua – run perevir to check transformations
--
-- Copyright: © 2024-2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License: MIT

local pandoc  = require 'pandoc'
local perevir = require 'perevir'

--- Command line arguments
local arg = arg

local opts = perevir.parse_args(arg)
local pereviryalnyk = perevir.Pereviryalnyk.new{
  accept = opts.accept,
  runner = perevir.TestRunner.new {
    ioformats = {
      write = {
        typst = function (doc, attr)
          attr = attr or pandoc.Attr{}
          local wopts = pandoc.WriterOptions{}
          wopts.template = attr.attributes.template
          local format = {
            format = 'typst',
            extensions = pandoc.format.extensions 'typst'
          }
          return pandoc.write(doc, format, wopts)
            :gsub('\n+$', '')  -- trim final newlines
        end,
      }
    }
  },
}
pereviryalnyk:test_files_in_dir(opts.path)
