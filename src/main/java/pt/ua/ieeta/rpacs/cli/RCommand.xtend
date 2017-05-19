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
	
	@Option(names = "--search", help = true, description = "Search in r-pacs document store. Default to --from 0 --size 100")
	public String search
	
	@Option(names = "--from", help = true, description = "Search results from a position")
	public Integer from
	
	@Option(names = "--size", help = true, description = "Search results limit")
	public Integer size
	
	@Option(names = "--create", help = true,
		description = "Create document store indexes. Options:\n" +
						" all    -> create all r-pacs indexes \n" +
						" <name> -> create index with name"
	)
	public String create
	
	@Option(names = "--drop", help = true,
		description = "Drop document store indexes. Options:\n" + 
						" all    -> drop all r-pacs indexes \n" +
						" <name> -> drop index with name"
	)
	public String drop
	
	@Option(names = "--index", help = true,
		description = "Index r-pacs model from database to the document store. This can take some time! Options:" +
						" all    -> index all r-pacs indexes \n"
	)
	public String index
}