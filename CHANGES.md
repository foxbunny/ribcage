# Ribcage changelog

This changelog logs all changes in the Ribcage API that may (and usually will)
affect your code.

## 0.2.2

### `ribcage` mamespace created in `main.js` not in other modules

This change only affects developers that load Ribcage using `<script>` tag. Use
of Ribcage as AMD modules is not affected by this change. 

The UMD wrappers no longer check for existence of properties in the global
`ribcage` object. Instead `main.js` module will now set up that namespaces, so
it now needs to be loaded before any other Ribcage module. Failure to load
`main.js` before other modules will throw `TypeError: Cannot set property X of
undefined` exception or similar.

This change is intentional, and it is meant to further reduce the complexity of
the UMD wrappers.

There is no need to update to 0.2.2 except for purely cosmetic reasons.

## 0.2.1

Fixes a few silly bugs and typos that made it into 0.2.0. 

## 0.2.0

0.2.0 is has some serious bugs that render it useless. Use 0.2.1 or above.

### Removed SOAP support

The `SoapModel` is no longer part of Ribcage. A 
[separate project](https://github.com/foxbunny/ribcage-soap) is being prepared
for public release, which will provide both `SoapModel` and `SoapCollection`
objects for Ribcage.

As a result, Ribcage no longer requires jquery.soap and jquery.xml2json
dependencies when loading the main module.

### `BaseModel` and model mixins

The models now have the same structure as views. They all share the same
`BaseModel`, and the model modules now all export `Model` and `mixin`
properties instead of a single object that represents the constructor. This
change is not backwards compatible and it __will break your code__.

By extension, the main Ribcage module will now also have a `modelMixins`
property which provides access to model mixins.

### UMD wrapper rewrite

The UMD wrapper has been rewritten in all modules and are now somewhat easier
to decipher, and a few bugs were fixed.

## 0.1.0

### `FormView` extends `TemplateView`

This means that mixing in the `TemplateView` mixin into `FormView` view is no
longer needed in order to provide the template rendering features. This has no
effect on existing `FormView` views that add the `TemplateView` mixin, but the 
mixin is redundant and may safely be omitted.
