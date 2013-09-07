# # Documenting source code
#
# Documentation is as important as the actual code. Even if the code is not
# going to be used by anyone other than you, you should still invest time in
# properly documenting it as if someone else will use it.
#
# Proper documentation helps you navigate the code base and also provides a
# sanity check for your implementation.
#
# ::TOC::
#
# ## `extract_docs` script
#
# This code base uses the `extract_docs` script to extract documentation from
# the inline comments.
#
# To run the script use NodeJS:
#
#     node path/to/extract_docs.js SOURCE DOCS
#
# The `SOURCE` argument is the directory of the source code. The `DOCS`
# directory is where you want the output Markdown files to end up.
#
# ## Formatting conventions
#
# Because this script is somewhat crude and quirky, there are some formatting
# rules that you need to follow in order to generate readable documentation.
#
# ### Markdown
#
# The files will be written out as `.mkd` files, and some of the generated
# markups such as references and table of contents will use the Markdown
# syntax. Format all your comments as Markdown unless you have a better idea or
# wish to hack the script.
#
# ### Use multiline comments
#
# All inline comments must use the multiline comment style, and not block
# comments. Block comments are completely ignored.
#
#     # ## Section
#     #
#     # This is a good comment.
#     #
#
#     ###
#     ## Section
#
#     This comment will be ignored.
#     ###
#
# ### Leave a blank line under paragraphs and headings
#
# You must always have a blank line under all headings, paragraphs and code
# blocks. For example:
#
#     # This is a proper paragraph.
#     #
#
# Becuase the script first extracts all comments from the code, and then merges
# them into paragraphs, it will merge any lines that are not separated by a
# blank line, even if there is code between them in your file.
#
# ### Add an extra space before bulletted lists
#
# When using bulletted lists, add two spaces between the first-level bullet and
# the comment character.
#
#     #  + This is a list item
#     #  + This is another list item
#     #
#
# As with paragraphs and headings, you need to leave a blank line after the
# list.
#
# ### Word-wrapping
#
# The length of line and word-wrapping does not really matter. All paragraphs
# will be merged an re-wrapped to 79-character lines.
#
# ### Cross refrences
#
# All headers in the generated document will have an anchor tag. The anchor's
# name is generated using [DaHelpers](https://github.com/foxbunny/dahelpers/)
# `#slug()` method. If you want to make references to haders, you should get a
# feel for what the `#slug()` method will generate. Here are some examples:
#
#     Some header               some-header
#     camelCase                 camelcase
#     #func(arg, anotherArg)    func-arg-anotherarg
#     Class.property            class-property
#
# Unfortunately, there is currently no clever way to refer to section anchors
# other than guessing the `#slug()` method's output.
#
# Note that you can have two sections that would generate the exact same anchor
# name. For example `#foo()` and `foo` both geneate an anchor name of 'foo'.
# This shouldn't happen in a code base that has a sane naming convention (e.g.,
# name for attributes, verbs for method names), but there is no solution for
# this problem other than renaming the sections.
#
# ### Comments that should be ignored
#
# Sometimes we like to leave notes to ourselves that appear as comments but
# should not be included in the documentation. There are a few ways to mark up
# such comments. One obvious way is to use block comments. However, block
# comments end up in the generated JavaScript. If that is not what you want,
# you can use double-hash comments:
#
#     ## This comment is ignored
#
# Note that some editors (Vim for example) may get confused by the double-hash
# comments.
#
# ### Table of comments
#
# If you want to include the table of comments in the generated document,
# simply add a paragraph to your inline comments that says `::TOC::`. Here's an
# example:
#
#     # ::TOC::
#     #
#
# Note that, again, you must leave a blank line after the `::TOC::` paragraph.
#
# ## General guidelines
#
# These guidelines apply to code that I write, which are mostly AMD modules
# with UMD wrappers. Some of the things mentioned here may not apply to the
# code you write.
#
# ### Include an introduction at the top of the file.
#
# Start your source file with an introduction. Use the level 1 heading to give
# the file a proper title suggestive of what the user will find in it. Also
# give a one- or two-paragraph summary of the purpose of the code.
#
# ### Note about module exports
#
# Add a short summary of the module's exports just above the UMD wrapper. This
# helps developers not only understand what the module exports, but also how to
# read the UMD wrapper if it has complex dependency-handling logic or assigns
# the exports to global object. For example:
#
#     # This module is in UMD format and will create `ribcage.views.BaseView`,
#     # `ribcage.viewMixins.BaseView`, and `ribcage.views.baseView` globals if
#     # not used with an AMD loader such as RequireJS.
#     #
#
#     if typeof define isnt 'function' or not define.amd
#       @require = (dep) =>
#         (() =>
#           switch dep
#             when 'backbone' then @Backbone
#             else null
#        )() or throw new Error "Unmet dependency #{dep}"
#      @define = (factory) =>
#        module = @ribcage.views.baseView = factory @require
#        @ribcage.views.BaseView = module.View
#        @ribcage.viewMixins.BaseView = module.mixin
#
# ### Note about module dependencies
#
# Group all module dependency `require`s at the top of the module definition,
# and add notes about dependencies just above the list. For example:
#
#     # This module depends on jQuery and Underscore.
#     #
#     $ = require 'jquery'
#     _ = require 'underscore'
#
# ### Use headings to outline the structure of your code
#
# This might sound obvious but use heading levels to show the relationship
# between different parts of your code. For example, a class may have a level 2
# heading, while its methods have level 3.
#
# ### Using JSDoc
#
# Should you use [JSDoc](http://usejsdoc.org/)? That's completely up to you.
# This script will not do anything special with them, though.
#

{readFileSync, writeFileSync, readdirSync, statSync, existsSync,
  mkdirSync} = require 'fs'
dahelpers = require 'dahelpers'

commentRe = /^ *(?:#|# (.*))$/

compile = (filename) ->
  contents = readFileSync filename, encoding: 'utf-8'
  lines = contents.split '\n'  # yes, we don't care about CRLF

  paragraphs = []  # Comment paragraphs

  ## Iterate all lines, and only collect those that represent a standard
  ## comment.  As we iterate the lines, we also group paragraphs together. We
  ## assume that each paragraph will be separated from another by a single
  ## blank line.

  ((block) ->
    lines.forEach (line, idx) ->
      match = line.match commentRe
      if match
        if match[1]?
          block.push match[1]
        else
          paragraphs.push block
          block = []
      return
  ) []

  ## Now we go over paragraphs (that are currently represented by an array of
  ## strings, and we either word-wrap them, or we keep them as they are. Rule
  ## is simple. If there is at least one space at the beginning of the first
  ## line of a paragraph, we leave the paragraph as is (we simply concatenate
  ## it leaving one newline at the end of each line). Otherwise we first merge
  ## the paragraph into a single string, and then we word-wrap it to
  ## 79-character lines.

  paragraphs = paragraphs.map (paragraph) ->
    return ''if not paragraph[0]
    if paragraph[0][0] is ' '
      # We have space at beginning of line 1
      paragraph.join('\n') + '\n'
    else
      dahelpers.wrap(paragraph.join(' '))

  ## We will also add anchor tags for all headers and build the ToC

  toc = ''

  paragraphs = paragraphs.map (paragraph) ->
    if paragraph[0] is '#'

      ## Calculate the ToC level
      m = paragraph.match /^(#+) (.*)$/
      tocLevel = m[1].length
      title = m[2]
      tocSymbol = if tocLevel % 2 then '-' else '+'
      tocIndent = new Array(2 + ((tocLevel - 2) * 2)).join ' '

      ## Calcualte the anchor hash
      hash = dahelpers.slug paragraph

      ## Add item to ToC
      if tocLevel > 1
        toc += tocIndent + tocSymbol + ' [' + title + '](#' + hash + ')\n'

      ## Add the anchor to the actual heading
      paragraph + ' ' + dahelpers.a '', name: hash
    else
      paragraph

  ## Output the results to STDOUT
  mkd = paragraphs.join '\n\n'
  mkd = mkd.replace '::TOC::', toc

  return mkd

processDir = (dir, target, skip) ->
  ## Get the contents of the current directory
  index = readdirSync dir

  if not existsSync target
    mkdirSync(target)

  ## Iterate the index and compile all .cofffee files
  for f in index
    continue if f is skip
    path = "#{dir}/#{f}"
    fstat = statSync path
    if fstat.isDirectory()
      console.log "Entering directory #{path}"
      processDir path, "#{target}/#{f}"
    else
      name = f.split('.')[0..-2].join '.'
      ext = f.split('.')[-1..][0]
      if ext is 'coffee'
        console.log "Processing #{path}"
        mkd = compile path
        console.log "Writing to #{target}/#{name}.mkd"
        writeFileSync "#{target}/#{name}.mkd", mkd, encoding: 'utf-8'
      else
        console.log "Skipping #{path}"

sourceDir = process.argv[2]
targetDir = process.argv[3]
skip = process.argv[4]

processDir(sourceDir, targetDir, skip)
