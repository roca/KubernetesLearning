from jinja2 import Template
import json

def handle(event, context):
    input = json.loads(event.body)

    # TODO implement
    t = Template("{{greeting}} {{name}}")
    res = t.render(name=input["name"], greeting=input["greeting"])

    return {
        "statusCode": 200,
        "body": res
    }