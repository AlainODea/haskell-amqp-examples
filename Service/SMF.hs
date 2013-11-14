{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ExtendedDefaultRules #-}
{-# OPTIONS_GHC -fno-warn-type-defaults #-}
module Service.SMF
       ( handleDiscover,
         handleCommand
       ) where

import Shelly
import Prelude hiding (FilePath)
import qualified Data.Text as T
default (T.Text)

handleDiscover :: IO String
handleDiscover = return "smf"

handleCommand :: String -> IO ()
handleCommand "stop tomcat" = do
  stopService "tomcat"
handleCommand "start tomcat" = do
  startService "tomcat"
handleCommand unsupported = do
  putStrLn $ "unsupported command " ++ unsupported

stopService :: T.Text -> IO ()
stopService service = shelly $ verbosely $ do
  run_ "svcadm" ["disable", service]

startService :: T.Text -> IO ()
startService service = shelly $ verbosely $do
  run_ "svcadm" ["enable", service]

