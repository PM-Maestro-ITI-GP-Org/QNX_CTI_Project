This Raspberry PI support is specific to RPI5.

So it has a number of assumptions for that target when one
specifies the 'rpi5' type. Those assumptions get baked
into the final image(s) automatically and can't be overriden
in the traditional manner.

To work around this, give up on using the `rpi5` type provided
by mkqnximage and instead make an rpi5 specific one based on the
original rpi5 type.
