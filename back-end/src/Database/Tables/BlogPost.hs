{-# LANGUAGE DeriveAnyClass       #-}
{-# LANGUAGE DeriveGeneric        #-}
{-# LANGUAGE FlexibleInstances    #-}
{-# LANGUAGE OverloadedStrings    #-}
{-# LANGUAGE StandaloneDeriving   #-}
{-# LANGUAGE TemplateHaskell      #-}
{-# LANGUAGE TypeFamilies         #-}
{-# LANGUAGE TypeSynonymInstances #-}

module Database.Tables.BlogPost where

import           AppPrelude
import           Data.Aeson
import           Database.Beam
import           Database.Beam.Backend.SQL.SQL92
import           Database.Beam.Postgres
import           Database.Beam.Postgres.Syntax
import           Database.MasterEntity
import           Database.PostgreSQL.Simple.FromField
import           GHC.Generics                         (Generic)

type BlogPostT = AppEntity BlogPostBaseT

data BlogPostBaseT f
    = BlogPostBaseT
    { title         :: Columnar f Text
    , content       :: Columnar f Text
    , submit_status ::  Columnar f BlogPostSubmitStatus
    } deriving (Generic)

instance Beamable BlogPostBaseT

data BlogPostSubmitStatus =
    SUBMITTED | SAVED
      deriving
        ( Generic
        , Show
        , Read
        , Eq
        , Ord
        , FromJSON
        , ToJSON
        )

deriving instance FromBackendRow Postgres BlogPostSubmitStatus

instance FromField BlogPostSubmitStatus where
  fromField f mdata = do
    readResult <- readMaybe <$> fromField f mdata
    case readResult of
        Nothing -> returnError ConversionFailed f "Could not 'read' value for 'BlogPostSubmitStatus'"
        Just x -> pure x

instance HasSqlValueSyntax PgValueSyntax BlogPostSubmitStatus where
  sqlValueSyntax = autoSqlValueSyntax

type BlogPost = BlogPostBaseT Identity
type BlogPostEntity = BlogPostT Identity

instance ToJSON BlogPost
instance FromJSON BlogPost

