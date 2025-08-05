
//Made using http requests and servers. Would make sense to add Express for better handling of controllers and routing
const http = require('node:http');
const { env } = require('node:process');
const { URL } = require('url');


const { PORT = 8080, HOST = "127.0.0.1", NODE_ENV = "Development" } = process.env;
const welcomeMessage = process.env.Message || "Hello World!";

console.log(`Running in ${NODE_ENV} mode`);



const server = http.createServer((req, res) => {
    const { method, url } = req;
    const parsedUrl = new URL(url, `http://${req.headers.host}`);
    const pathname = parsedUrl.pathname;
    
    // Route: GET /version
    //Would make sense to return things like build version here.
    if (method === 'GET' && pathname === '/version') {
        res.statusCode = 200;
        res.end("Version endpoint reached");
    }

    // Route: GET /health
    //Would make sense to check the connection status of databases and other critical features here, if any fails return status 500
    if (method === 'GET' && pathname === '/health') {
        res.statusCode = 200;
        res.end("Health endpoint reached");
    }
    
    if (method === 'GET' && pathname === '/') {
        res.statusCode = 200;
        res.setHeader('Content-Type', 'text/plain');
        res.end(welcomeMessage);
    }
});

server.on('clientError', (err, socket) => {
    socket.end('HTTP/1.1 400 Bad Request\r\n\r\n');
});

server.listen(PORT, HOST, () => {
    console.log(`Server running at http://${HOST}:${PORT}/`);
});




