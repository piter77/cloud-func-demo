package com.pret.piter

import io.micronaut.core.annotation.Introspected
import io.micronaut.http.MediaType
import io.micronaut.http.annotation.Body
import io.micronaut.http.annotation.Controller
import io.micronaut.http.annotation.Get
import io.micronaut.http.annotation.Post
import io.micronaut.http.annotation.Produces
import java.time.LocalDateTime

@Controller("/cloudFuncDemo")
class CloudFuncDemoController {

    var map: MutableMap<String, String> = mutableMapOf()

    @Produces(MediaType.TEXT_PLAIN)
    @Get("/time")
    fun pret(): String {
        return "It's ${LocalDateTime.now().toLocalTime()}"
    }

    @Produces(MediaType.TEXT_PLAIN)
    @Get("/micronaut")
    fun micronaut(): String {
        if (map.isEmpty()) {
            map["foo"] = "bar"
            return "Hello Micronaut!"
        } else {
            return "Hello Again!"
        }
    }

    @Post
    fun post(@Body inputMessage: SampleInputMessage): SampleReturnMessage {
        return SampleReturnMessage("Hello ${inputMessage.name}, thank you for sending the message")
    }
}

@Introspected
data class SampleInputMessage(val name: String)

@Introspected
data class SampleReturnMessage(val returnMessage: String)
