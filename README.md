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

## Documentation

Until we set up a proper documentation page, please look at the CoffeeScript
sources. They are well-documented and the final documentation will be generated
from them anyway. :)

## Reporting bugs

Please report bugs to 
[Ribcage's GitHub issue tracker](https://github.com/foxbunny/ribcage/issues).
