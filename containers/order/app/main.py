from fastapi import FastAPI

app = FastAPI()


@app.get('/order')
async def order():
    return {'service': 'order'}
