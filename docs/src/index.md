```@meta
CurrentModule=StringAnalysis
```

# Introduction

StringAnalysis is a package for working with strings and text. It is a hard-fork from [TextAnalysis.jl](https://github.com/JuliaText/TextAnalysis.jl) designed to provide a richer, faster and orthogonal API.


## What is new?
This package brings several changes over `TextAnalysis.jl`:
 - Added the [Okapi BM25](https://en.wikipedia.org/wiki/Okapi_BM25) statistic
 - Added dimensionality reduction with [sparse random projections](https://en.wikipedia.org/wiki/Random_projection)
 - Added co-occurence matrix
 - Improved latent semantic analysis
 - Re-factored text preprocessing API
 - DTM and similar have documents as columns
 - Parametrized many of the objects (`DocumentTermMatrix`, `AbstractDocument`s)
 - Element type specification for `each_dtv`, `each_hash_dtv`
 - Extended `DocumentMetadata` fields
 - Simpler API i.e. less exported methods
 - Many of the repetitive functions are now automatically generated (see [metadata.jl](https://github.com/zgornel/StringAnalysis.jl/blob/master/src/metadata.jl), [preprocessing.jl](https://github.com/zgornel/StringAnalysis.jl/blob/master/src/preprocessing.jl))
 - Improved test coverage
 - Many bugfixes and small extensions

## Installation

Installation can be performed from either inside or outside Julia.

### Git cloning
The `StringAnalysis` repository can be downloaded through git:
```
$ git clone https://github.com/zgornel/StringAnalysis.jl
```

### Julia REPL
The package can be installed from inside Julia with:
```
using Pkg
Pkg.add(StringAnalysis)
```
will download the latest registered build of the package and add it to the current active development environment.

