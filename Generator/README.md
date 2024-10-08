# Needle Code Generator

## Building and developing

### Compiling from source:

First resolve the dependencies:

```
$ swift package update
```

You can then build from the command-line:

```
$ swift build
```

Or create an Xcode project and build using the IDE:

```
$ swift package generate-xcodeproj --xcconfig-overrides xcode.xcconfig
```
Note: For now, the xcconfig is being used to pass in the DEBUG define.

### Debugging

Needle is intended to be heavily multi-threaded. This makes stepping through the code rather complicated. To simplify the debugging process, set the `SINGLE_THREADED` enviroment variable for your `Run` configuration in the Scheme Editor to `1` or `YES`.

### Structure of generated code 

The shortest way to describe the code generated by needle is that its primary purpose is to create classes that conform to all the `*Dependency` protocols in your application code.

In order to do this needle creates Provider classes which perform the job just described. So the providers need to have a number of vars, one for each of the vars in the protocol. The body of these vars is quite simple. Typically, something like:
```
var imageCache: ImageCaching {
    return rootComponent.imageCache
}
```
The `rootComponent` property is of a concrete type so the body of the var above is quite safe. If the component does not have the var we're asking for, the compiler will error out. If the type of the var in the rootComponent has a different type, again, the compiler will complain.

In order to instantiate one of these providers, needle needs to pass it references to each of the components from which the provider will be getting vars from. This is where the slightly unsafe portion of the generated code comes in. 

needle creates a tree of how all the components are linked together in a tree. It then generates snippets like ` rootComponent: parent4(component) as! RootComponent` (parent4 is a one-liner that is equivalent to `component.parent.parent.parent.parent`)

### Structure of generated code with dynamic runtime lookup

A new option for the generated code is to create extensions of all the various `Component` classes. Therse extensions will ge used to fill in dictionaries. There will be 2 dictionaries. The first one is easy to describe. It allows us to convert keypaths to strings. Ideally this would be something Swift supports, but unfortunately, there is no such functionality available today. The second dictionary is one that contains closures to fetch the vars using a string key. 

Using dynimic member lookup, we'll intercept the references to the dependecny property and get a keypath. The first step is to convert the keypath into a string using the dictionary mentioned above. Then, the Component class will walk up the parents (using the parent property) and keep checking if the second dictionary contains the property we're looking for. The string key used will have a combination of the var name and type.
