# Ribcage

Ribcage for your Backbone

Ribcage is a set of mixins and libraries to make developing 
[Backbone](http://backbonejs.org/) applications easier and more strucutred.
It's also a set of opinions on how you should develop a web application.

## Requirements

Ribcage depends on Backbone (surprised?) and jQuery, and also two more jQuery
plugins if you use the `SoapModel` model. These are:

 + [jquery.soap](http://plugins.jquery.com/soap/)
 + [jquery.xml2json](http://code.google.com/p/jquery-xml2json-plugin/)

## Installing

Ribcage modules are in UMD format. This means that you can use them either as
AMD modules (with loaders like [RequireJS](http://requirejs.org/)), or load
them using `<script>` tags.

When used with `<script>` tags, the modules will do basic dependency checking,
so you will get exceptions in many cases.

When using Ribcage as AMD modules, you can either require the entire Ribcage
using the `ribacge/ribcage` module, or you can require indivudal parts by
loading them as separate modules. Note that some Ribcage modules may depend on
other Ribcage modules (e.g., `TemplateView` depends on `BaseView`).

## Installing using volo

If you are using [volo](http://volojs.org/), you can safely install ribcage
using the usual `add` command:

    volo add foxbunny/ribcage

It will be installed into `lib/ribcage` directory, and `lib/ribcage.js` module
will be created as an alias for `lib/ribcage/main.js`. 

The CoffeeScript sources are located in the `src` directory, and are _not_
installed by volo. If you want to use the CoffeeScript version instead, simply
manually copy them into your project.

## Minified and concatenated version

No, there are none and there will never be. Why minify a single component when
there's a whole project to be minified?

## Documentation

Until we set up a proper documentation page, please look at the CoffeeScript
sources. They are well-documented and the final documentation will be generated
from them anyway. (Incidentally, if you know of a good documentation generator
that actually works, please let me know.)

## Reporting bugs

Please report bugs to 
[Ribcage's GitHub issue tracker](https://github.com/foxbunny/ribcage/issues).
