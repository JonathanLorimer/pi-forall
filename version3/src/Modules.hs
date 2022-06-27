{- pi-forall language -}

-- | Tools for working with multiple source files
module Modules (getModules, ModuleInfo (..)) where

import Parser (parseModuleFile, parseModuleImports)
import Syntax

import Text.ParserCombinators.Parsec.Error (ParseError)

import Control.Monad.Except

import Data.Graph qualified as Gr
import Data.List (nub, (\\))
import System.Directory
import System.FilePath

{- | getModules starts with a top-level module, and gathers all of the module's
 transitive dependency. It returns the list of parsed modules, with all
 modules appearing after its dependencies.
-}
getModules ::
    (Functor m, MonadError ParseError m, MonadIO m) =>
    [FilePath] ->
    String ->
    m [Module]
getModules prefixes top = do
    toParse <- gatherModules prefixes [ModuleImport top]
    mapM reparse toParse

data ModuleInfo = ModuleInfo
    { modInfoName :: MName
    , modInfoFilename :: String
    , modInfoImports :: [ModuleImport]
    }

{- | Build the module dependency graph.
   This only parses the imports part of each file; later we go back and parse all of it.
-}
gatherModules ::
    (Functor m, MonadError ParseError m, MonadIO m) =>
    [FilePath] ->
    [ModuleImport] ->
    m [ModuleInfo]
gatherModules prefixes ms = gatherModules' ms []
  where
    gatherModules' [] accum = return $ topSort accum
    gatherModules' ((ModuleImport m) : ms') accum = do
        modFileName <- getModuleFileName prefixes m
        imports <- moduleImports <$> parseModuleImports modFileName
        let accum' = ModuleInfo m modFileName imports : accum
        let oldMods = map (ModuleImport . modInfoName) accum'
        gatherModules' (nub (ms' ++ imports) \\ oldMods) accum'

{- | Generate a sorted list of modules, with the postcondition that a module
 will appear _after_ any of its dependencies.
-}
topSort :: [ModuleInfo] -> [ModuleInfo]
topSort ms = reverse sorted
  where
    (gr, lu) =
        Gr.graphFromEdges'
            [ (m, modInfoName m, [i | ModuleImport i <- modInfoImports m])
            | m <- ms
            ]
    lu' v = let (m, _, _) = lu v in m
    sorted = [lu' v | v <- Gr.topSort gr]

-- | Find the file associated with a module.
getModuleFileName ::
    (MonadIO m) =>
    [FilePath] ->
    MName ->
    m FilePath
getModuleFileName prefixes modul = do
    let makeFileName prefix = prefix </> mDotPi
        -- get M.pi from M or M.pi
        mDotPi =
            if takeExtension s == ".pi"
                then s
                else s <.> "pi"
        s = modul
        possibleFiles = map makeFileName prefixes
    files <- liftIO $ filterM doesFileExist possibleFiles
    if null files
        then
            error $
                "Can't locate module: " ++ show modul
                    ++ "\nTried: "
                    ++ show possibleFiles
        else return $ head files

-- | Fully parse a module (not just the imports).
reparse ::
    (MonadError ParseError m, MonadIO m) =>
    ModuleInfo ->
    m Module
reparse (ModuleInfo _ fileName _) = parseModuleFile fileName
