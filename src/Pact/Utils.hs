module Pact.Utils where


import Data.Text



tshow :: Show a => a -> Text
tshow = pack . show
