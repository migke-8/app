//> using platform JVM
//> using file ./project.scala
//> using dep com.softwaremill.sttp.tapir::tapir-vertx-server:1.13.31
//> using dep com.lihaoyi::scalatags:0.13.1

import sttp.tapir.*
import scala.concurrent.Future
import scala.concurrent.ExecutionContext
import scala.io.StdIn
import io.vertx.core.Vertx
import io.vertx.ext.web.Router
import scala.concurrent.Await
import sttp.tapir.server.vertx.VertxFutureServerInterpreter
import sttp.tapir.server.vertx.VertxFutureServerInterpreter.*
import scala.concurrent.ExecutionContext.Implicits.global
import scalatags.Text.all.*
import java.io.File
import java.io.InputStream
import java.nio.charset.StandardCharsets

val port = 8080

@main def run = {
  val vertx = Vertx.vertx()
  val server = vertx.createHttpServer()
  val router = Router.router(vertx)
  val page =
    s"<!DOCTYPE HTML>${html(head(script(src := "./bundle.js", defer := "defer")), body())}"
  def attach(router: Router) = {
    VertxFutureServerInterpreter().route(
      Data.helloPoint.serverLogicSuccess((Unit) => Future.successful(page))
    ).apply(router)
    VertxFutureServerInterpreter().route(
      endpoint.get
        .in("bundle.js")
        .out(stringBody)
        .serverLogicSuccess((Unit) => Future(jsBundle))
    ).apply(router)
  }

  attach(router)
  println(s"server listening at port: ${port}...")
  Await.result(
    server.requestHandler(router).listen(port).asScala,
    scala.concurrent.duration.Duration.Inf
  )
}
def jsBundle =
  val stream: InputStream = Data.getClass.getResourceAsStream("/bundle.js")
  if stream == null then
    throw new RuntimeException("bundle.js não foi encontrado no classpath!")

  try
    new String(stream.readAllBytes(), StandardCharsets.UTF_8)
  finally
    stream.close()
