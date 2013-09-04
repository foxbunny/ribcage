# Ribcage changelog

This changelog logs all changes in the Ribcage API that may (and usually will)
affect your code.

## 0.3.1

### Fixed typo in a require statement in the main module.

## 0.3.0

### `LocalStorageModel` refactor and `LocalStore` class

The `LocalStorageModel` has been completely reworked and *will break your
models*.

Namely, it is now possible to store more than one instance of a model under the
same key, as the underlaying layer has been converted to use the new
`LocalStore` interface, which simulates a RESTful service that persists the
data in localStorage. This has an undersired effect on models that were
previous singleton.

To explain the difference, lets take a look at some code first. In the versions
prior to 0.3.0, the `LocalStorageModel` would only store one instance per key.

    var MyLocalStoredModel = ribcage.models.LocalStorageModel.extend({
        storageKey: 'foo';
    });

    var instance = new MyLocalStoredModel({id: 'foo', someValue: 1});
    instance.save();

The above used to work fine. Later on, if you want to fetch an instance, you
would simply do:

    var instance = new MyLocalStoredModel();
    instance.fetch();

And this would bind all the saved data, so you could:

    instance.get('id');  // returns 'foo'

This is no longer possible. Because the `LocalStorageModel` now behaves pretty
much like any Backbone model, it will not be able to fetch and instance that
does not have an ID. It will also not be able to create a new instance with
preset ID unless you pass the `forceCreate` setting.

    var instance = new MyLocalStoredModel({id: 'foo'});
    instance.save()  // Fails
    instance.save(null, {forceCreate: true});  // Works

What `forceCreate` does is, if it detects that the model has an 'id', it will
still force the 'create' method instead of 'update', and it will instruct the
`LocalStore` API to retrieve an object with the same ID if it is already there.
Note that this does not perform an update.

Here is a few things to watch out for when using forceCreate for singleton 
models:

    var instance = new MyLocalStoredModel({id: 'foo'});
    instance.set({bar: 1});
    instance.save(null, {forceCreate: true});

    // A bit later...
    var instance = new MyLocalStoredModel({id: 'foo'});
    instance.save(null, {forceCreate: true});
    instance.get('bar');  // returns 1

    // A bit later...
    var instance = new MyLocalStoredModel({id: 'foo', bar: 2});
    instance.save(null, {forceCreate: true});
    instance.get('bar');  // still returns 1
    instance.attributes.bar;  // also 1

    // Finally...
    var instance = new MyLocalStoredModel({id: 'foo', bar: 2});
    instance.save();  // <-- no forceCreate
    instance.get('bar');  // now returns 2 because we did not forceCreate

The last example shows that without `forceCreate`, the operation is an update
rather than a create or read, which is standard Backbone behavior. The
operation fails when there is no object with given ID, as it should.

## 0.2.4

### Fixed broken `LocalStorageModel`

LocalStorageModel was not extending the BaseView with its own mixin so its
functionality as a model had been completely broken. This is now fixed and
LocalStorageModel now works correctly.

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
