{-# LANGUAGE OverloadedStrings #-}
module Main (
  module Main
  ) where
import Network.AMQP
import qualified Data.ByteString.Lazy.Char8 as BL
import qualified ServiceManager as Agent
import qualified Service.SMF as Plugin

main :: IO ()
main = do
  example_agentMain

example_stopAllTomcats = do
  runExample $ sendToAgents "stop tomcat"

example_agentMain = do
  runExample runAgent

runExample :: (Channel -> IO a) -> IO ()
runExample example = do
  conn <- openConnection "127.0.0.1" "/" "guest" "guest"
  chan <- openChannel conn
  example chan
  getLine -- wait for keypress
  closeConnection conn

runAgent :: Channel -> IO ConsumerTag
runAgent chan = do
  (myQueue, _, _) <- declareQueue chan newQueue
  declareExchange chan newExchange {
    exchangeName = allAgents, exchangeType = "fanout"}
  bindQueue chan myQueue allAgents routingKey
  consumeMsgs chan myQueue Ack (
    Agent.receiveCommand Plugin.handleCommand)

allAgents = "allAgents"
routingKey = "myKey"

sendToAgents :: String -> Channel -> IO ()
sendToAgents msg chan = do
  publishMsg chan allAgents routingKey
      newMsg {msgBody = (BL.pack msg),
              msgDeliveryMode = Just Persistent}
