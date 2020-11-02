# Transforming a historical, German encyclopedia XML corpus to TEI

XSLT files documenting all transformations done to the original encyclopedia corpus (please see the paper "Twenty-two Historical Encyclopedias Encoded in TEI: a New Resource for the Digital Humanities" for more information).

The original encyclopedia corpus:\
[![DOI](https://zenodo.org/badge/doi/10.5281/zenodo.4159491.svg)](http://dx.doi.org/10.5281/zenodo.4159491)

The transformed corpus and its ODD:\
[![DOI](https://zenodo.org/badge/doi/10.5281/zenodo.4039569.svg)](http://dx.doi.org/10.5281/zenodo.4039569)

### Basic transformation

This folder contains one corresponding XSL script per encylopedia as well as two general XSL scripts. In the script **import_rules.xsl**, the overarching article structure of all encyclopedia documents has been attended to, so that encyclopedia-specific exceptions could be handled separately. The enyclopedia XSL scripts therefore each contain a customized TEI header and templates for any exceptions (e.g. handling missing IDs, missing tags, or just treating tags differently compared to import_rules.xsl). The other general XSL script, **preface.xsl**, contains overarching templates for all basic front matters. Results of this first conversion are used for the second set of XSL transformations. Note that some files of this initial transformation are not valid TEI yet, as all IDs linking to other encyclopedia entries still need to be resolved in a second step.

### Linking

The script **link_entries.xsl** resolves all references, i.e. provides all `@targets` with the actual `xml:id` of that entry. Note that not all references could be resolved due to major inconsistencies between the reference string and the target headword string. Sometimes the referenced entry might even not be found by manual search. Unresolved references therefore have no `@target` attribute. A second XSL file (**meyers_refs.xsl**) was necessary to resolve all links in Meyers. Additionally, the script **anchors.xsl** replaces all anchor-type references with regular references.

### Final adjustments

The script **unify.xsl** can be used to shorten all IDs uniformly and remove unneccessary whitespace (just for visual purposes). It also contains the final decision to make `<def>` elements contain `<p>` elements.

#### Transformation overview - `article` to `entry` structure (excluding encyclopedia specific rules)
| Basic Structure | |
| ------------- |:-------------:| 
| `article`     | `entry @xml:id @xml:lang` | 
| `articlegroup`      | `div`      |  
| `lem` | `form @type="lemma"/term `    |   
| `text`    | `sense @xml:id/def`    | 
| `p`      | `p`      | 
|`lemfloat` & `lemsupfloat` | `term @type="headword"`|
| `link` | `ref @type="entry" @target `    |

| Footnotes | |
| ------------- |:-------------:| 
| `fn `    |` note` | 
| `fntext  `    | `note @type="footnote" @xml:id `    |  
| `fnref` | `ref @type="footnote" @target`     |   

| Figures | |
| ------------- |:-------------:| 
| `image `    | `figure @xml:id/graphic @url` | 
| `imagetext`      | `figure/head`     |  
| `imagefindtext` |` figure/figDesc`     |
| `a @name` | -     |
| `a @href` | `ref @type="figure" @target `    |

| Other | |
| ------------- |:-------------:| 
| `ol` & `ul `    | `list` | 
| `li `     | `item `   |  
| `table`| `table`   |
| `tr` |`row` |
| `td` | `cell`    |
| `verse` | `lg `   |
|`verse/p` |` l` |
|`gr`| `foreign @xml:lang="el"` |
