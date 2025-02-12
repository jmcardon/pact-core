{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE DeriveFoldable #-}
{-# LANGUAGE DeriveTraversable #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE OverloadedStrings #-}
-- |
-- Copyright :  (c) Emily Pillmore 2019-2019
-- License   :  BSD-2-Clause
-- Maintainer:  Emily Pillmore <emily@kadena.io>
-- Stability :  experimental
-- Portability: non-portable
--
-- Type analysis environment with primitive types and names
--
module Pact.Environment where


import GHC.Generics

import Control.DeepSeq
import Control.Lens

import Data.HashMap.Strict as HashMap
import Data.Text

import Pact.AST.SourcePos
import Pact.Kinds
import Pact.Names
import Pact.Types


data Environment = Environment
  { _envNames :: !(HashMap Text (Type SourceAnn))
  , _envTypes :: !(HashMap Text ((Kind SourceAnn), TypeSort))
  } deriving (Show, Generic, NFData)

envNames :: Lens' Environment (HashMap Text (Type SourceAnn))
envNames = lens _envNames (\t b -> t { _envNames = b })

envTypes :: Lens' Environment (HashMap Text ((Kind SourceAnn), TypeSort))
envTypes = lens _envTypes (\t b -> t { _envTypes = b })


instance Semigroup Environment where
  Environment n t <> Environment n' t' = Environment (n <> n') (t <> t')

instance Monoid Environment where
  mempty = Environment HashMap.empty HashMap.empty

initEnvironment :: Environment
initEnvironment = mempty
  & envNames .~ primNames
  & envTypes .~ primTypes

primKind :: Kind SourceAnn
primKind = KType initSourceAnn

primType :: Prim -> Type SourceAnn
primType = TyBuiltin initSourceAnn

primTypes :: HashMap Text (Kind SourceAnn, TypeSort)
primTypes = HashMap.fromList
  [ ("integer", (primKind, Primitive))
  , ("boolean", (primKind, Primitive))
  , ("time   ", (primKind, Primitive))
  , ("string" , (primKind, Primitive))
  , ("decimal", (primKind, Primitive))
  , ("guard"  , (primKind, Security))
  ]

primNames :: HashMap Text (Type SourceAnn)
primNames = HashMap.fromList
  [ ("true" , primType TyBool)
  , ("false", primType TyBool)
  ]
