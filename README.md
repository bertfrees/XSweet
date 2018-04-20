# XSweet docx to html extraction and more

*Including extraction of document contents from MS Office Open XML into HTML*

Wendell Piez for Coko Foundation, from July 2016

You will need an XSLT 3.0 processor. Everything has been tested with SaxonHE.

These are XSLT stylesheets, designed to specify transformations from XML or HTML source documents, into other XML or HTML documents. The main goal of XSweet is to provide for conversion of data encoded in MS Word's data description format (`docx`), into a clean and serviceable HTML. Secondary goals include operations in support of text encoding and editing, including varyious cleanup and data enhancement processes.

In addition to stylesheets that provide for extraction and simple post-processing, kept in the XSweet/XSweet repo, the XSweet/HTMLevator repository provides stylesheets for generalized operations in support of data enhancement conversions including the inference and encoding of structural divisions in documents from their formatting. These are experimental, will not always work, and cannot be guaranteed to work without corresponding constraints in the workflow, which are not always possible.

The XSweet/editoria_typescript repo stores stylesheets developed specifically to support HTML import by Editoria (link needed).

## Why use XSweet

- Works reasonably well with defaults
- Works reasonably well on arbitrary inputs
- Alternatively, you can assert control
  - Deciding which phases (transformations) to include or exclude
  - Using runtime switches
- Acts like a black box, except you can open it up and alter it: due to its "get-insidability", XSweet is adaptable and extensible
- Versatile, powerful, scalable: doorway to XSLT

## Not exclusive

Please feel free to use XSweet along with other tools that do parts or all of the job. There is no wrong way to use XSweet. You might find you like another extractor, but like to use XSweet to clean up afterwards. Or maybe the other way around.

## "Pick your pathway"

For regular use, the hardest thing about XSweet will be deciding what's the best way for you (in your own situation) to set up and run. There are many choices and the same approach isn't always the best for everyone.

run it once and forget about it, or run it regularly and routinely?
run it on one document at a time, or run it on big piles of documents?

Picking your pathway entails two choices: first, picking your framework or glue language. Then, selecting from and arranging for the different transformations to be executed on your data. (Choosing your menu.) Since XSweet's first challenge was Word data conversion, the working assumption is that your input data might (may) be an XML document artifact using WordML (an XML format maintained internally in Word docx files); but components of XSweet might also be useful in document processing architectures especially XML-based HTML processing architectures.

Since this endeavor is open-ended and everyone's solution will be different, XSweet offers several "prefab pathways" using several different "glue" solutions, for inspection and emulation. An easy way to start is just to try whichever of these you think will work best for you.

## Why XSLT


XSLT is a 4GL not a 3GL. As such, it would ideally be regarded as compatible with and complimentary to any 3GL, 4GL or mix. The problem domain addressed by XSLT is the arbitrary, rules-based *transformation* of a tree-shaped data structure, into another such tree-shaped structure. Such structures are typically presented (where XSLT is used) as representations of intellectual objects encoded using formal notation in documents or files, "tagged" as XML. (They may also persist in systems as "XML document objects" of some nature, not only as text files on disks.) From a user's point of view, this ordinarily means there will be a "source file" or "source document", namely a data instance (nominally, an XML or other file of some kind). And there will be an operation to perform, a process to run, which results in the production of "transformation output". This is (again typically) another XML or HTML file or document, representing the changes, translations or embellishments provided to the original by the transformation (or "stylesheet"). By itself, this simple model solves no problems at all. Without specifying what transformation to perform -- without providing a stylesheet -- nothing happens (or nothing very useful). But provide stylesheets, and XSLT becomes a kind of generalized information machine tool, working at any level of scale from very large and copious, to very granular. Among the many uses it can be put to are quite complex translations to help reconcile and align different encoding systems, describing what are (nominally and actually) very different kinds of data.

Because XSLT is specifically designed for the task, it provides many built in features and functionalities specifically to reduce the task overhead ordinarily related to these operations. As a language, XSLT is sometimes described as verbose, as indeed line for line, it is. But XSLT code bases tend also to be relatively small, because at the level of the transformation itself and its own mappings and operations, its expression is extremely concise and economical. Because it is Turing complete and because it is able, natively, to process its own outputs, XSLT is also, incidentally, capable at least in theory of specifying *any* transformation that can be specified in terms of its data model. Theory aside, it is extremely versatile and extensible.

## XSweet architecture: mix and match your XSLTs

XSweet's various components are all written as straightforward "one-up" XSLT transformations with some meta-transformations and other advanced stuff mixed in. (The basic "extract from docx" transformation combines five separate transformation steps, operating on a zip file unzipped on the system.) Operations are broken out discreetly so a single XSLT typically has a single task to do. This enables flexible mixing and matching of the transformations called in for particular pipelines. If there's something you don't need, you simply leave it out. If there's something you want, you add it.

This does mean you need some kind of glue (language, environment) to string the transformations together.

### Platforms to choose from

* Straight up Saxon (OSS XSLT processor) running on file system
  * orchestrate with shell script (e.g. bash or Windows batch scripting)
* Developers' 'build' technology
  * `make` or Apache Ant have both been used to sequence transformations
* Scripting in your favorite or best-available language: PHP, Perl, Python, Ruby etc.
* XML-based processing architecture on a web server
  * Apache Cocoon (Java), Uche Ogbuji's Akara (Python)
* XProc, the W3C XML pipelining technology
* XML stack such as XML db
  * eXist-db or BaseX (server or executable script)

Almost all of these will use Saxon in one form or another. We look forward to the day when other conformant processors are ubiquitous.

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
