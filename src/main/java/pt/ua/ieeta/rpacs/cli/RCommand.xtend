package pt.ua.ieeta.rpacs.cli

import picocli.CommandLine.Command
import picocli.CommandLine.Option

@Command(
	name = "rpacs", footer = "Copyright(c) 2017",
	description = "R-PACS CLI Helper"
)
class RCommand {
	@Option(names = #["-h", "--help"], help = true, description = "Display this help and exit.")
	public boolean help
	
	@Option(names = "--drop", help = true, description = "Drop all r-pacs indexes in the document store.")
	public boolean drop
	
	@Option(names = "--index", help = true, description = "Index r-pacs model from database to the document store. This can take some time!")
	public boolean index
}