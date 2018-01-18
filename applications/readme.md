# XSweet docx to html extraction and more

These are XSLT stylesheets, designed to specify transformations from XML or HTML source documents, into other XML or HTML documents. The main goal of XSweet is to provide for conversion of data encoded in MS Word's data description format (`docx`), into a clean and serviceable HTML.

Why use XSweet

- Works reasonably well without further setting
- Works reasonably well on arbitrary inputs
- Acts like a black box, but isn't
- Adaptable, extensible
- Versatile, powerful, scalable: doorway to XSLT

These are all written as straightforward "one-up" XSLT transformations with some meta-transformations and other advanced stuff mixed in. Operations are broken out very discretely so a single XSLT typically has a single task to do. This enables mixing and matching the transformations called in for particular pipelines. If there's something you don't need, you simply leave it out. If there's something you want, you add it.

Transformations are achieved in chains called "pipelines". There are many ways of building and operating a pipeline of transformations, running all the way from old-fashioned scripts, to full-fledged pipelining technologies such as those supporting XProc, a specification of W3C that describes a pipeline language. XSweet will work irrespective of the particular approach to putting its inputs and outputs together.

A pipelining or "glue" framework must be able to:

* access arbitrary resources (XML documents and XSLTs)
* apply an XSLT transformation to an XML document and capturing the results
  * offer a way of setting runtime parameters in XSLT invocation
* sequence transformations together, so the output of one becomes input to another
* persisting (writing, serializing) final results or making them available

As long as some provision is made for all these, just about anything will work. In addition to 

Here is an example of an XSweet pipeline using bash:

[bash example]

(The most primitive possible kind: in particular, notice how a separate VM is started for every single transformation. Nonetheless throughput may be tolerable for many purposes.)

Here is an example in PHP:

Here is an XProc pipeline:

Here is a prototype XSweet "XSLT puppeteer"

Other ways this could be done: Windows batch files (these are like bash scripts); XML services under a servlet architecture e.g. Apache Cocoon; XML db e.g. BaseX; XMLsh (CL tool library).




