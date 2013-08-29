# Ribcage

Ribcage for your Backbone

Ribcage is a set of mixins and libraries to make developing 
[Backbone](http://backbonejs.org/) applications easier and more strucutred.
It's also a set of opinions on how you should develop a web application.

## Requirements

Ribcage depends on Backbone (surprised?) and jQuery.

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

## Application project template

There are two application templates that provide a good base and also a simple
example of a Ribcage app. One of them is
[for CoffeeScript developers](https://github.com/foxbunny/create-ribcage-app),
and the other is 
[for JavaScript ninjas](https://github.com/foxbunny/create-ribcage-app-js).

The templates set up a Backbone application with Ribcage. You can use volo to
kickstart a project using the templates:

    volo create my_app foxbunny/create-ribcage-app # CoffeeScript
    volo create my_app foxbunny/create-ribcage-app-js # JavaScript

## Minified and concatenated version

No, there are none and there will never be. Why minify a single component when
there's a whole project to be minified?

## Documentation

Please see the [Ribcage wiki](https://github.com/foxbunny/ribcage/wiki) for 
introductory and cookbook articles.

Until we set up a proper API documentation page, please look at the
CoffeeScript sources. They are well-documented and the final documentation will
be generated from them anyway. (Incidentally, if you know of a good
documentation generator that actually works, please let me know.)

## Reporting bugs

Please report bugs to 
[Ribcage's GitHub issue tracker](https://github.com/foxbunny/ribcage/issues).
