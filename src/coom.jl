# Co-occurence matrix
"""
    coo_matrix(::Type{T}, doc::Vector{AbstractString}, vocab::OrderedDict{AbstractString, Int}, window::Int, normalize::Bool)

Basic low-level function that calculates the co-occurence matrix of a document.
Returns a sparse co-occurence matrix sized `n × n` where `n = length(vocab)`
with elements of type `T`. The document `doc` is represented by a vector of its
terms (in order)`. The keywords `window` and `normalize` indicate the size of the
sliding word window in which co-occurrences are counted and whether to normalize
of not the counts by the distance between word positions.

# Examples
```
julia> using StringAnalysis
       doc = StringDocument("This is a text about an apple. There are many texts about apples.")
       docv = tokenize(text(doc))
       vocab = OrderedDict("This"=>1, "is"=>2, "apple."=>3)
       StringAnalysis.coo_matrix(Float16, docv, vocab, 5, true)
3×3 SparseArrays.SparseMatrixCSC{Float16,Int64} with 4 stored entries:
  [2, 1]  =  2.0
  [1, 2]  =  2.0
  [3, 2]  =  0.3999
  [2, 3]  =  0.3999
```
"""
function coo_matrix(::Type{T},
                    doc::Vector{<:AbstractString},
                    vocab::OrderedDict{<:AbstractString, Int},
                    window::Int,
                    normalize::Bool=true) where T<:AbstractFloat
    n = length(vocab)
    m = length(doc)
    coom = spzeros(T, n, n)
    # Count co-occurrences
    for (i, token) in enumerate(doc)
        @inbounds for j in max(1, i-window):min(m, i+window)
            wtoken = doc[j]
            nm = T(ifelse(normalize, abs(i-j), 1))
            row = get(vocab, token, nothing)
            col = get(vocab, wtoken, nothing)
            if i!=j && row != nothing && col != nothing
                coom[row, col] += one(T)/nm
                coom[col, row] = coom[row, col]
            end
        end
    end
    return coom
end


"""
Basic Co-occurrence Matrix (COOM) type.

# Fields
  * `coomm::SparseMatriCSC{T,Int}` the actual COOM; elements represent
co-occurrences of two terms within a given window
  * `terms::Vector{String}` a list of terms that represent the lexicon of
the document or corpus
  * `column_indices::OrderedDict{String, Int}` a map between the `terms` and the
columns of the co-occurrence matrix
"""
struct CooMatrix{T}
    coom::SparseMatrixCSC{T, Int}
    terms::Vector{String}
    column_indices::OrderedDict{String, Int}
end


"""
    CooMatrix{T}(crps::Corpus [,terms] [;window=5, normalize=true])

Auxiliary constructor(s) of the `CooMatrix` type. The type `T` has to be
a subtype of `AbstractFloat`. The constructor(s) requires a corpus `crps` and
a `terms` structure representing the lexicon of the corpus. The latter
can be a `Vector{String}`, an `AbstractDict` where the keys are the lexicon,
or can be omitted, in which case the `lexicon` field of the corpus is used.
"""
function CooMatrix{T}(crps::Corpus,
                      terms::Vector{String};
                      window::Int=5,
                      normalize::Bool=true) where T<:AbstractFloat
    column_indices = columnindices(terms)
    n = length(terms)
    coom = spzeros(T, n, n)
    for doc in crps
        docv = tokens(doc)
        coom .+= coo_matrix(T, docv, column_indices, window, normalize)
    end
    return CooMatrix{T}(coom, terms, column_indices)
end

CooMatrix(crps::Corpus, terms::Vector{String}; window::Int=5, normalize::Bool=true) =
    CooMatrix{DEFAULT_FLOAT_TYPE}(crps, terms, window=window, normalize=normalize)

CooMatrix{T}(crps::Corpus, lex::AbstractDict; window::Int=5, normalize::Bool=true
            ) where T<:AbstractFloat =
    CooMatrix{T}(crps, collect(keys(lex)), window=window, normalize=normalize)

CooMatrix(crps::Corpus, lex::AbstractDict; window::Int=5, normalize::Bool=true) =
    CooMatrix{DEFAULT_FLOAT_TYPE}(crps, lex, window=window, normalize=normalize)

CooMatrix{T}(crps::Corpus; window::Int=5, normalize::Bool=true) where T<:AbstractFloat = begin
    isempty(lexicon(crps)) && update_lexicon!(crps)
    CooMatrix{T}(crps, lexicon(crps), window=window, normalize=normalize)
end

CooMatrix(crps::Corpus; window::Int=5, normalize::Bool=true) = begin
    isempty(lexicon(crps)) && update_lexicon!(crps)
    CooMatrix{DEFAULT_FLOAT_TYPE}(crps, lexicon(crps), window=window, normalize=normalize)
end

# AbstractString, AbstractDocument methods
function CooMatrix{T}(doc,
                      terms::Vector{String};
                      window::Int=5,
                      normalize::Bool=true) where T<:AbstractFloat
    # Initializations
    column_indices = columnindices(terms)
    docv = tokens(doc)
    coom = coo_matrix(T, docv, column_indices, window, normalize)
    return CooMatrix{T}(coom, terms, column_indices)
end

CooMatrix(doc, terms::Vector{String}; window::Int=5, normalize::Bool=true
         ) where T<:AbstractFloat =
    CooMatrix{DEFAULT_FLOAT_TYPE}(doc, terms, window=window, normalize=normalize)

function CooMatrix{T}(doc; window::Int=5, normalize::Bool=true) where T<:AbstractFloat
    terms = unique(String.(tokens(doc)))
    CooMatrix{T}(doc, terms, window=window, normalize=normalize)
end

CooMatrix(doc; window::Int=5, normalize::Bool=true) where T<:AbstractFloat =
    CooMatrix{DEFAULT_FLOAT_TYPE}(doc, window=window, normalize=normalize)


"""
    coom(c::CooMatrix)

Access the co-occurrence matrix field `coom` of a `CooMatrix` `c`.
"""
coom(c::CooMatrix) = c.coom

"""
    coom(entity, eltype=DEFAULT_FLOAT_TYPE [;window=5, normalize=true])

Access the co-occurrence matrix of the `CooMatrix` associated
with the `entity`. The `CooMatrix{T}` will first have to
be created in order for the actual matrix to be accessed.
"""
coom(entity, eltype::Type{T}=DEFAULT_FLOAT_TYPE;
        window::Int=5, normalize::Bool=true) where T<:AbstractFloat =
    coom(CooMatrix{T}(entity, window=window, normalize=normalize))
