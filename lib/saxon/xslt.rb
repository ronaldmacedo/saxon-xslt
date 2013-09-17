require 'saxon/s9api'

module Saxon
  def self.XSLT(xslt_path_or_io)
    XSLT::Stylesheet.new(xslt_path_or_io)
  end

  module XSLT
    class Stylesheet
      include Saxon::SourceHelpers

      def initialize(xslt_path_or_io)
        @processor = S9API::Processor.new(false)
        @compiler = @processor.newXsltCompiler()
        @xslt = @compiler.compile(to_stream_source(xslt_path_or_io))
      end

      def transform(xdm_node_or_xml_path_or_io)
        output = S9API::XdmDestination.new
        if xdm_node_or_xml_path_or_io.respond_to?(:getNodeKind)
          xml = xdm_node_or_xml_path_or_io
        else
          xml = @processor.newDocumentBuilder().build(to_stream_source(xdm_node_or_xml_path_or_io))
        end
        transformer = @xslt.load
        transformer.setInitialContextNode(xml)
        transformer.setDestination(output)
        transformer.transform
        output.getXdmNode
      end
    end
  end
end
