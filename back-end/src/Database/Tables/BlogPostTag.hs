{-# LANGUAGE DeriveAnyClass       #-}
{-# LANGUAGE DeriveGeneric        #-}
{-# LANGUAGE FlexibleInstances    #-}
{-# LANGUAGE OverloadedStrings    #-}
{-# LANGUAGE StandaloneDeriving   #-}
{-# LANGUAGE TemplateHaskell      #-}
{-# LANGUAGE TypeFamilies         #-}
{-# LANGUAGE TypeSynonymInstances #-}

module Database.Tables.BlogPostTag where

import           AppPrelude
import           Data.Aeson            (FromJSON, ToJSON)
import           Database.Beam
import           Database.MasterEntity
--import           Database.Tables.BlogPost (BlogPostBaseT (..))
import           GHC.Generics          (Generic)


data TagBaseT f
    = TagBaseT
    { tagName :: Columnar f Text
    } deriving (Generic)

instance Beamable TagBaseT

type TagT = AppEntity TagBaseT
type TagEntity = TagT Identity
type Tag = TagBaseT Identity

instance ToJSON Tag
instance FromJSON Tag

--data BlogPostTagBaseT f
--    = BlogPostTagBaseT
--    { blogPostId  :: PrimaryKey (AppEntity BlogPostBaseT) f
--    , blogPostTag :: PrimaryKey TagT f
--    } deriving (Generic)
--
--instance Beamable BlogPostTagBaseT
--
--type BlogPostTagT = AppEntity BlogPostTagBaseT
--type BlogPostTagEntity = BlogPostTagT Identity
--type BlogPostTag = BlogPostTagBaseT Identity
--
--instance ToJSON BlogPostTag
--instance FromJSON BlogPostTag

