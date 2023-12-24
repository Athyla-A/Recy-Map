import numpy as np
import json
from rdflib import Graph
from rdflib import URIRef, BNode, Literal, Namespace
from rdflib.namespace import CSVW, DC, DCAT, DCTERMS, DOAP, FOAF, ODRL2, ORG, OWL, PROF, PROV, RDF, RDFS, SDO, SH, SKOS, SOSA, SSN, TIME, VOID, XSD
from SPARQLWrapper import SPARQLWrapper, JSON
from flask import Flask, jsonify

app = Flask(__name__)


g = Graph()
# Load RDF data from a file
g = SPARQLWrapper("http://localhost:8890/sparql")


# Query for all triples with a specific predicate
query = """
    SELECT ?domain ?range
    WHERE {
     GRAPH <http://localhost:8890/DAV/recy_map> {
        ?domain <http://recy-map.rf.gd/recy_map#what_type> ?range
    }
}
"""

# Run the query
g.setQuery(query)
g.setReturnFormat(JSON)
results = g.query().convert()
list1 = []
# Print the results
for result in results["results"]["bindings"]:
    print(result["range"]["value"])
    list1.append(result["range"]["value"])

print("\n")
query = """
    SELECT ?domain ?range
    WHERE {
     GRAPH <http://localhost:8890/DAV/recy_map> {
        ?domain <http://recy-map.rf.gd/recy_map#num_lat> ?range
    }
}
"""

# Run the query
g.setQuery(query)
g.setReturnFormat(JSON)
results = g.query().convert()
list2 = []
# Print the results
for result in results["results"]["bindings"]:
    print(result["range"]["value"])
    list2.append(result["range"]["value"])
    
print("\n")
query = """
    SELECT ?domain ?range
    WHERE {
     GRAPH <http://localhost:8890/DAV/recy_map> {
        ?domain <http://recy-map.rf.gd/recy_map#num_lng> ?range
    }
}
"""

# Run the query
g.setQuery(query)
g.setReturnFormat(JSON)
results = g.query().convert()
list3 = []
# Print the results
for result in results["results"]["bindings"]:
    print(result["range"]["value"])
    list3.append(result["range"]["value"])

print("\n")
query = """
    SELECT ?domain ?range
    WHERE {
     GRAPH <http://localhost:8890/DAV/recy_map> {
        ?domain <http://recy-map.rf.gd/recy_map#What_name> ?range
    }
}
"""

# Run the query
g.setQuery(query)
g.setReturnFormat(JSON)
results = g.query().convert()
list4 = []
# Print the results
for result in results["results"]["bindings"]:
    print(result["range"]["value"])
    list4.append(result["range"]["value"])
    
print("\n")
query = """
    SELECT ?domain ?range
    WHERE {
     GRAPH <http://localhost:8890/DAV/recy_map> {
        ?domain <http://recy-map.rf.gd/recy_map#what_id> ?range
    }
}
"""

# Run the query
g.setQuery(query)
g.setReturnFormat(JSON)
results = g.query().convert()
list5 = []
# Print the results
for result in results["results"]["bindings"]:
    print(result["range"]["value"])
    list5.append(result["range"]["value"])


print("\n")
lists = np.array([list1, list2, list3, list4, list5], dtype=object).T
y =  lists.tolist()
print(y)

json_map = {
    "data":{
        "id": list5,
        "lat": list2,
        "lng": list3,
        "title": list4,
        "type": list1
    },
}

# Convert to JSON format
json_data = json.dumps(json_map, indent=2)  # indent for pretty formatting

# Print or use the JSON data as needed
print(json_data)

# If you want to write the JSON data to a file
with open("output.json", "w") as json_file:
    json.dump(json_map, json_file, indent=2)
    
@app.route('/get_data', methods=['GET'])
def get_data():
    # ... Your existing code to generate 'json_map'
    return jsonify(json_map)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)