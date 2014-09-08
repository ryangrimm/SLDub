About
=====

SLDub makes it easy to annotate UIViews in iOS. It's origin comes from
first-use help overlays and a desire to render them dynamically without the use
of images.

SLDubView is a UIView that can be placed on top of any other UIView. The
background can be set to any color with any level of transparency. A single tap
can be configured to dismiss/remove the SLDubView from the view hierarchy.

SLDubItem is used to actually annotate an item that is visible behind the
SLDubView. SLDubItem allows you to configure a "portal" as a UIBezierPath that
punches a hole through the SLDubView background color, allowing the underlying
view to be seen. It can also be configured with a description for the portal
and a location/size for the description.

The description can be left or right aligned, centered or justified, its height
can be automatically resized to the content and the color can be configured as
well.

The portal and the description are connected by a line being drawn between them.
The direction that the line leaves the portal and enters the description can be
configured as well or calculated automatically based on their positions and the
text alignment of the description.

Multiple SLDubItems can be placed on a single SLDubView. Changes to the
SLDubItem configuration can be made at any time, even after the item is
visible. These changes are rendered in one swoop by calling the [SLDubView
render:] method. This allows the changes to be animated if desired.

TODO
====

* Avoid drawing line on top of text rect
* Swipe to animate between items
