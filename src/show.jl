# Show methods
show(io::IO, d::AbstractDocument) = print(io, "A $(typeof(d))")

show(io::IO, crps::Corpus) = print(io, "A Corpus with $(length(crps.documents)) documents")

show(io::IO, dtm::DocumentTermMatrix{T}) where T = begin
    p, n = size(dtm.dtm)
    println(io, "A $(p)x$(n) DocumentTermMatrix{$T}")
end

show(io::IO, coom::CooMatrix{T}) where T = begin
    n, p = size(coom.coom)
    println(io, "A $(n)x$(p) CooMatrix{$T}")
end

titleize(str::AbstractString) = begin
    join(map(uppercasefirst, strip.(split(str, "."))), ". ","")
end

show(io::IO, md::DocumentMetadata) = begin
    _id = ifelse(isempty(md.id), "<no ID>", md.id)
    _name = ifelse(isempty(md.name), "<no name>", "\"$(titleize(md.name))\"")
    _author = ifelse(isempty(md.author), "<unknown author>", "by $(titlecase(md.author))")
    _edition_year = ifelse(isempty(md.edition_year), "?", md.edition_year)
    _published_year = ifelse(isempty(md.published_year), "?", md.published_year)
    printstyled(io, "$(_id)", bold=true)
    printstyled(io, " $(_name)",
                    " $(_author)",
                    " $(_edition_year)",
                    " ($(_published_year))")
end


# Summary methods
"""
    summary(doc)

Shows information about the document `doc`.
"""
function summary(d::AbstractDocument)
    o = ""
    o *= "A $(typeof(d))\n"
    o *= " * Language: $(language(d))\n"
    o *= " * Name: $(name(d))\n"
    o *= " * Author: $(author(d))\n"
    o *= " * Timestamp: $(timestamp(d))\n"
    td = typeof(d)
    if td<:TokenDocument|| td<:NGramDocument
        o *= " * Snippet: ***SAMPLE TEXT NOT AVAILABLE***"
    else
        l = length(text(d))
        sl = clamp(50, 0, l)
        dots = ifelse(sl<l, "...","")
        sample_text = replace(text(d)[1:sl], r"\s+"=>" ")
        o *= " * Snippet: \"$(sample_text)$(dots)\""
    end
    return o
end

"""
    summary(crps)

Shows information about the corpus `crps`.
"""
function summary(crps::Corpus)
    n = length(crps.documents)
    n_s = sum(map(d -> typeof(d)<:StringDocument, crps.documents))
    n_f = sum(map(d -> typeof(d)<:FileDocument, crps.documents))
    n_t = sum(map(d -> typeof(d)<:TokenDocument, crps.documents))
    n_ng = sum(map(d -> typeof(d)<:NGramDocument, crps.documents))
    o = ""
    o *= "A Corpus with $n documents:\n"
    o *= " * $n_s StringDocument's\n"
    o *= " * $n_f FileDocument's\n"
    o *= " * $n_t TokenDocument's\n"
    o *= " * $n_ng NGramDocument's\n\n"
    o *= "Corpus's lexicon contains $(lexicon_size(crps)) tokens\n"
    o *= "Corpus's index contains $(index_size(crps)) tokens"
    return o
end

