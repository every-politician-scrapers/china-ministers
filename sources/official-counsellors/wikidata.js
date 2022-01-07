const fs = require('fs');
let rawmeta = fs.readFileSync('meta.json');
let meta = JSON.parse(rawmeta);

module.exports = function () {
  return `SELECT DISTINCT (STRAFTER(STR(?item), STR(wd:)) AS ?wdid)
               ?name ?wdLabel ?source ?sourceDate
               (STRAFTER(STR(?held), '/statement/') AS ?psid)
        WHERE {
          VALUES ?positionItem { wd:Q835630 wd:Q508368 wd:Q7143813 wd:Q4122271 }

          # Who currently holds those positions
          ?item wdt:P31 wd:Q5 ; p:P39 ?held .
          ?held ps:P39 ?positionItem ; pq:P580 ?start .
          FILTER NOT EXISTS { ?held wikibase:rank wikibase:DeprecatedRank }
          OPTIONAL { ?held pq:P582 ?end }

          FILTER NOT EXISTS { ?held wikibase:rank wikibase:DeprecatedRank }
          FILTER (?start < NOW())
          FILTER (!BOUND(?end) || ?end > NOW())
          FILTER NOT EXISTS { ?item wdt:P570 [] }

          OPTIONAL {
            ?held prov:wasDerivedFrom ?ref .
            ?ref pr:P854 ?source FILTER CONTAINS(STR(?source), '${meta.source.url}') .
            OPTIONAL { ?ref pr:P1810 ?sourceName }
            OPTIONAL { ?ref pr:P1932 ?statedName }
            OPTIONAL { ?ref pr:P813  ?sourceDate }
          }

          OPTIONAL { ?item rdfs:label ?wdLabel FILTER(LANG(?wdLabel) = "${meta.source.lang.code}") }
          BIND(COALESCE(?sourceName, ?wdLabel) AS ?name)

          OPTIONAL { ?positionItem wdt:P1705  ?nativeLabel   FILTER(LANG(?nativeLabel)   = "${meta.source.lang.code}") }
          OPTIONAL { ?positionItem rdfs:label ?positionLabel FILTER(LANG(?positionLabel) = "${meta.source.lang.code}") }
          BIND(COALESCE(?statedName, ?nativeLabel, ?positionLabel) AS ?position)
        }
        # ${new Date().toISOString()}
        ORDER BY STR(?name) STR(?position) ?began ?wdid ?sourceDate`
}
