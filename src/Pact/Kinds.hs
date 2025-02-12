{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE DeriveFoldable #-}
{-# LANGUAGE DeriveTraversable #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE OverloadedStrings #-}
-- |
-- Copyright :  (c) Emily Pillmore 2019-2019
-- License   :  BSD-2-Clause
-- Maintainer:  Emily Pillmore <emily@kadena.io>
-- Stability :  experimental
-- Portability: non-portable
--
-- Pact kind system
--
module Pact.Kinds
( -- * Data
  Kind(..)
  -- * Prisms
, _KType
, _KArrow
, _KRow
, _KHole
, _KConstraint
, _KCapability
  -- * Traversals
, subkinds
) where


import GHC.Generics

import Control.DeepSeq
import Control.Lens
import Data.Text

-- | The Pact kind system
--
data Kind a
  = KType a
    -- ^ The kind of concrete types (i.e. * or Type)
  | KArrow a (Kind a) (Kind a)
    -- ^ The kind of kind-level arrows Type -> Type
  | KRow a [Kind a]
    -- ^ The kind of row-types
  | KHole a {-# UNPACK #-} !Int
    -- ^ The kind of unknown kinds Kind : Kind - used for unification
  | KConstraint a
    -- ^ The kind of functor constraints of modules
  | KCapability a
    -- ^ The kind of security primitives a la capabilities
  deriving (Eq, Ord, Functor, Foldable, Traversable, NFData, Generic)
makePrisms ''Kind

instance Show a => Show (Kind a) where
  show = \case
    KType _ -> "Type"
    KArrow _ t u -> show t <> " -> " <> show u
    KHole _ i -> "_" <> show i
    KConstraint _ -> "Constraint"
    KRow _ r -> show $ fmap show r
    KCapability _ -> "Capability"

-- | Traverse over all subkinds of a given kind
--
subkinds :: Traversal' (Kind a) (Kind a)
subkinds f = \case
  KArrow a k k' -> KArrow a <$> f k <*> f k'
  KRow a ks -> KRow a <$> traverse f ks
  k -> pure k
{-# INLINABLE subkinds #-}
