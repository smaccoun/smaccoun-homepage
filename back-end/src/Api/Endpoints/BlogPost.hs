{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}

module Api.Endpoints.BlogPost where


import           AppPrelude
import           Config.AppConfig
import           Data.Text                          (Text)
import           Data.Time.Clock
import qualified Data.UUID                          as U (UUID, toText)
import           Data.Vector                        (Vector)
import           Database.PostgreSQL.Simple
import           Database.PostgreSQL.Simple.FromRow
import           Database.Transaction

data BlogPostR =

    BlogPostR
      {title        :: Text
      ,content      :: Text
      ,submitStatus :: Text
      ,tags         :: Vector Text
      ,updatedAt    :: UTCTime
      ,createdAT    :: UTCTime
      }

instance FromRow BlogPostR where
    fromRow = BlogPostR
                <$> field -- title
                <*> field -- content
                <*> field -- submitStatus
                <*> field -- tags
                <*> field -- updatedAt
                <*> field -- createdAt

createBlogPost :: (HasDBConn r, MonadReader r m, MonadIO m)
        => Text
        -> Text
        -> Text
        -> Vector Text
        -> m [BlogPostR]
createBlogPost title' content' submitStatus' tags' =
    runCustomQuery
            "SELECT * FROM mk_blog_post(?, ?, ?, ?);"
            (title', content', submitStatus', tags')


getBlogPosts :: (HasDBConn r, MonadReader r m, MonadIO m)
           => m [BlogPostR]
getBlogPosts =
    runCustomQuery baseGetPostQuery ()

getBlogPost :: (HasDBConn r, MonadReader r m, MonadIO m)
           => U.UUID
           -> m [BlogPostR]
getBlogPost uuid' =
    runCustomQuery fullQuery [id']
    where
        id' = U.toText uuid'
        fullQuery = baseGetPostQuery <> " WHERE id=?"

baseGetPostQuery :: Query
baseGetPostQuery =
    "SELECT * FROM blog_post_vw;"

