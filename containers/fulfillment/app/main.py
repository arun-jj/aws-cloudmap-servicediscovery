from fastapi import FastAPI

app = FastAPI()


@app.get('/fulfillment')
async def fulfillment():
    return {'service': 'fulfillment'}
