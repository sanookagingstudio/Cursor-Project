require("http").createServer((_, res) => {
  res.writeHead(200, {"Content-Type": "text/plain"});
  res.end("SAS FRONTEND READY");
}).listen(3000, "0.0.0.0", () => {
  console.log("Frontend listening on 0.0.0.0:3000");
});
