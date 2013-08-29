# Ribcage changelog

## 0.1.0

### `FormView` extends `TemplateView`

This means that mixing in the `TemplateView` mixin into `FormView` view is no
longer needed in order to provide the template rendering features. This has no
effect on existing `FormView` views that add the `TemplateView` mixin, but the 
mixin is redundant and may safely be omitted.
