module ServiceManager
       ( receiveDiscover
       , receiveCommand
       ) where

import Network.AMQP
import qualified Data.ByteString.Lazy.Char8 as BL

receiveDiscover :: IO () -> (Message,Envelope) -> IO ()
receiveDiscover handleDiscover (msg, env) = do
  receiveMessage (\_ -> handleDiscover) (msg, env)

receiveCommand :: (String -> IO ()) -> (Message,Envelope) -> IO ()
receiveCommand handleCommand (msg, env) = do
  receiveMessage handleCommand (msg, env)

receiveMessage :: (String -> IO()) -> (Message,Envelope) -> IO ()
receiveMessage handleMessage (msg, env) = do
  handleMessage $ BL.unpack $ msgBody msg
  ackEnv env
