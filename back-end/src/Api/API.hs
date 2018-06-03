{-# LANGUAGE DeriveAnyClass       #-}
{-# LANGUAGE DeriveGeneric        #-}
{-# LANGUAGE FlexibleInstances    #-}
{-# LANGUAGE OverloadedStrings    #-}
{-# LANGUAGE StandaloneDeriving   #-}
{-# LANGUAGE TemplateHaskell      #-}
{-# LANGUAGE TypeFamilies         #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE UndecidableInstances #-}

module Api.API where

import           Api.Endpoints.Login
import           Api.Endpoints.User
import           AppPrelude
import           Config.AppConfig
import           Data.Text                           (Text)
import           Database.Crud
import           Database.Schema
import           Database.Tables.BlogPost
import           Database.Tables.BlogPostTag
import           Models.User                         (UserResponse (..))
import           Servant
import           Servant.Auth.Server
import           Servant.Auth.Server.SetCookieOrphan ()

---------------------------------------------------------------
type Protected
   =    UserAPI
   :<|> CUDEntityAPI "blogPost" BlogPostEntity BlogPost

protected :: AuthResult UserResponse -> ServerT Protected AppM
protected (Authenticated user) =
       userServer user
  :<|> cudEntityServer blogPostTable

protected _                    = throwAll err401

type Unprotected =
       "health" :> Get '[JSON] Text
  :<|> LoginAPI
  :<|> REntityAPI "blogPost" BlogPostEntity
  :<|> REntityAPI "tags" TagEntity

unprotectedProxy :: Proxy Unprotected
unprotectedProxy = Proxy

unprotected :: JWTSettings -> ServerT Unprotected AppM
unprotected jwts =
       return "Okay"
  :<|> loginServer jwts
  :<|> rEntityServer blogPostTable
  :<|> rEntityServer tagTable

type API auths =
       (Auth auths UserResponse :> Protected)
  :<|> Unprotected

api :: Proxy (API '[JWT])
api = Proxy


serverAPI :: JWTSettings -> ServerT (API auths) AppM
serverAPI jwts = protected :<|> unprotected jwts

