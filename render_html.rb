#Ruby script to render markdown documentation to HTML for static site.
require 'open-uri'
require 'Redcarpet'

class Renderer
  def self.convert(fn, outdir)
    header = '''<head>
            <meta charset="UTF-8">
            <!--[if IE]><meta http-equiv="X-UA-Compatible" content="IE=edge"><![endif]-->
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Vaquero Documentation</title>
            <link rel="stylesheet" type="text/css" href="../doc.css">
            <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Open+Sans:300,300italic,400,400italic,600,600italic%7CNoto+Serif:400,400italic,700,700italic%7CDroid+Sans+Mono:400">
            <style>
                .markdown-body {
                    box-sizing: border-box;
                    min-width: 200px;
                    max-width: 980px;
                    margin: 0 auto;
                    padding: 45px;
                }
            </style>
        </head><article class="markdown-body">'''
    text=File.open(fn).read
    renderer = Redcarpet::Render::HTML.new()
    markdown = Redcarpet::Markdown.new(renderer)
    output = markdown.render(text)
    #parse the name of filename minus the .txt
    x = fn.split("/")
    outfn = x[x.length-1].split(".")[0] + ".html"
    File.open("docs/" + outdir + "/" + outfn, 'w') { |file| file.write(header + output) }
  end
end
