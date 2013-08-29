# Ribcage changelog

This changelog logs all changes in the Ribcage API that may (and usually will)
affect your code.

## 0.2.0

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
