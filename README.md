# XSweet docx to html extraction and more

*Including extraction of document contents from MS Office Open XML into HTML*

Wendell Piez for Coko Foundation, from July 2016

You will need an XSLT 3.0 processor. Everything has been tested with SaxonHE.

These are XSLT stylesheets, designed to specify transformations from XML or HTML source documents, into other XML or HTML documents. The main goal of XSweet is to provide for conversion of data encoded in MS Word's data description format (`docx`), into a clean and serviceable HTML. Secondary goals include sundry operations in support of that, including varyious cleanup and data enhancement processes.

The stylesheets in XSweet include other XSLTs as well, maintained in the HTMLevator project of this repository. These supplement the XSLTs kept in XSweet/XSweet. Projects may also find they wish to supplement these processes with post-processes: that's the idea of this architecture, is it makes this "drop in" easy.

Why use XSweet

- Works reasonably well with defaults*
- Works reasonably well on arbitrary inputs
- Alternatively, you can assert control
  - Deciding which phases (transformations) to include or exclude
  - Using runtime switches
- Acts like a black box, but isn't: due to its "get insidability", XSweet is adaptable and extensible
- Versatile, powerful, scalable: doorway to XSLT

* You do have to "pick your pathway"

Also, please use XSweet in addition to other tools that do parts or all of the job. There is no wrong way to use XSweet. You might find you like another extractor, but like to use XSweet to clean up afterwards. Or maybe the other way around.

## Pick your pathway

Picking your pathway entails two choices: first, picking your framework or glue language. Then, selecting from and arranging for the different transformations to be executed on your data. Since XSweet's first challenge was Word data conversion, the working assumption is that your input data might (may) be WordML (an XML format maintained internally in Word docx files); but components of XSweet might also be useful in document processing architectures especially XML-based HTML processing architectures.

Since this endeavor is open-ended and everyone's solution will be different, XSweet offers several "prefab pathways" using several different "glue" solutions, for inspection and emulation. An easy way to start is just to try whichever of these you think will work best for you.


## XSweet architecture: mix and match your XSLTs

XSweet's various components are all written as straightforward "one-up" XSLT transformations with some meta-transformations and other advanced stuff mixed in. (The basic "extract from docx" transformation combines five separate transformation steps, operating on a zip file unzipped on the system.) Operations are broken out discreetly so a single XSLT typically has a single task to do. This enables flexible mixing and matching of the transformations called in for particular pipelines. If there's something you don't need, you simply leave it out. If there's something you want, you add it.

This does mean you need some kind of glue (language, environment) to string the transformations together. Fortunately there are many ways of building and operating a pipeline of transformations, running all the way from old-fashioned scripts, to full-fledged pipelining technologies such as those supporting XProc, a specification of W3C that describes a pipeline language. As long as you can get them to work independently, XSweet will also work irrespective of the particular approach you use to putting its inputs and outputs together.

A pipelining or "glue" framework must be able to:

* access arbitrary resources (XML documents and XSLTs)
* apply an XSLT transformation to an XML document and capture the results
  * offer a way of setting runtime parameters in XSLT invocation
* sequence transformations together, so the output of one becomes input to the next, chains being of arbitrary length
* persist (write or serialize or otherwise save) final results and/or make them available in some useful way

As long as some provision is made for all these, just about anything will work. In addition to these features, having some kind of conditional logic and/or access to reasoning about the inputs, is nice to have in a shell language. 

Here is an example of an XSweet pipeline using bash:

[bash example, tbd]

(The most primitive possible kind: in particular, notice how a separate VM is started for every single transformation. Nonetheless throughput may be tolerable for many purposes.)

Here is an example in PHP [tbd]:

Here is an XProc pipeline [tbd]:

Here is a prototype XSweet "XSLT puppeteer" (all-XSLT dispatching XSLT ) [tbd]

Other ways this could be done: Windows batch files (these are like bash scripts); XML services under a servlet architecture e.g. Apache Cocoon; XML db e.g. BaseX; XMLsh (CL tool library).
