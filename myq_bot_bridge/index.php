<?php

$update = file_get_contents("php://input");
$myqUrl = getenv('MYQ_TELEGRAM_WEBHOOK_URL');
sendUpdateToMyq($myqUrl, $update);

//$path = "https://api.telegram.org/bot<yourtoken>";
//$chatId = $update["message"]["chat"]["id"];
//$message = $update["message"]["text"];
//
//if (strpos($message, "/weather") === 0) {
//    $location = substr($message, 9);
//    $weather = json_decode(file_get_contents("http://api.openweathermap.org/data/2.5/weather?q=".$location."&appid=mytoken"), TRUE)["weather"][0]["main"];
//    file_get_contents($path."/sendmessage?chat_id=".$chatId."&text=Here's the weather in ".$location.": ". $weather);
//}


function sendUpdateToMyq($url, $payload)
{
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $payload);
    curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type:application/json'));
# Return response instead of printing.
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
# Send request.
    $result = curl_exec($ch);
    curl_close($ch);
}
