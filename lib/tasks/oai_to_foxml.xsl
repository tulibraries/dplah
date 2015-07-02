<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns:foxml="info:fedora/fedora-system:def/foxml#"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:exsl="http://exslt.org/common"
  xmlns:ex="http://exslt.org/dates-and-times"
  extension-element-prefixes="exsl ex">

  <xsl:variable name="converted_path">
    <xsl:value-of select="records/manifest/converted_foxml_directory" />
  </xsl:variable>

  <xsl:variable name="contributing_institution">
    <xsl:value-of select="records/manifest/contributing_institution" />
  </xsl:variable>

  <xsl:variable name="intermediate_provider">
    <xsl:value-of select="records/manifest/intermediate_provider" />
  </xsl:variable>

  <xsl:variable name="collection_name">
    <xsl:value-of select="records/manifest/collection_name" />
  </xsl:variable>

  <xsl:variable name="provider_id_prefix">
    <xsl:value-of select="records/manifest/provider_id_prefix" />
  </xsl:variable>

  <xsl:variable name="identifier_pattern">
    <xsl:value-of select="records/manifest/identifier_pattern" />
  </xsl:variable>

  <xsl:variable name="identifier_token">
    <xsl:value-of select="records/manifest/identifier_token" />
  </xsl:variable>

  <xsl:variable name="rights_statement">
    <xsl:value-of select="records/manifest/rights_statement" />
  </xsl:variable>

  <xsl:variable name="set_spec">
    <xsl:value-of select="records/manifest/set_spec" />
  </xsl:variable>

  <xsl:variable name="partner">
    <xsl:value-of select="records/manifest/partner" />
  </xsl:variable>

  <xsl:variable name="common_repository_type">
    <xsl:value-of select="records/manifest/common_repository_type" />
  </xsl:variable>

  <xsl:variable name="endpoint_url">
    <xsl:value-of select="records/manifest/endpoint_url" />
  </xsl:variable>

  <xsl:variable name="pid_prefix">
    <xsl:value-of select="concat(records/manifest/pid_prefix, ':')" />
  </xsl:variable>

  <xsl:variable name="type">
    <xsl:value-of select="OaiRec" />
  </xsl:variable>

  <xsl:output method="xml" indent="yes"/>
    <xsl:template match="records/record">
      <xsl:copy>

      <xsl:variable name="current_time">
        <xsl:value-of select="ex:date-time()"/>
      </xsl:variable>

      <xsl:variable name="apos">'</xsl:variable>
      <xsl:variable name="separator">_</xsl:variable>

      <xsl:variable name="pid_raw">
        <xsl:value-of select="concat($provider_id_prefix, $separator, header/identifier)"/>
      </xsl:variable>

      <xsl:variable name="pid_local">
        <xsl:value-of select="substring($pid_raw, 1, 59)"/>
      </xsl:variable>

      <xsl:variable name="pid">
        <xsl:value-of select="concat($pid_prefix, $pid_local)" />
      </xsl:variable>

      <exsl:document method="xml" href="{$converted_path}/file_{$pid_local}.foxml.xml">        
        <xsl:element name="foxml:digitalObject"
          xmlns:foxml="info:fedora/fedora-system:def/foxml#"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
          <xsl:attribute name="VERSION">
            <xsl:value-of select="1.1"/>
          </xsl:attribute>
          <xsl:attribute name="PID"><xsl:value-of select="$pid"/></xsl:attribute>

          <xsl:attribute name="xsi:schemaLocation">info:fedora/fedora-system:def/foxml# http://www.fedora.info/definitions/1/0/foxml1-1.xsd</xsl:attribute>
          <foxml:objectProperties>
          <foxml:property NAME="info:fedora/fedora-system:def/model#state" VALUE="Active"/>
          <foxml:property NAME="info:fedora/fedora-system:def/model#label" VALUE="FOXML OAI-PMH"/>
          <foxml:property NAME="info:fedora/fedora-system:def/model#ownerId" VALUE=""/>
          <foxml:property NAME="info:fedora/fedora-system:def/model#createdDate" VALUE="{$current_time}"/>
          <foxml:property NAME="info:fedora/fedora-system:def/view#lastModifiedDate" VALUE=""/>
        </foxml:objectProperties>    

        <foxml:datastream ID="partner" STATE="A" CONTROL_GROUP="X" VERSIONABLE="true">
          <foxml:datastreamVersion ID="partner.0" LABEL="Partner supplied metadata" MIMETYPE="text/xml">
            <foxml:xmlContent>
              <fields>
                <xsl:call-template name="name-tag">
                  <xsl:with-param name="tag" select="'dc:title'" />
                  <xsl:with-param name="values" select="metadata/oai_dc:dc/dc:title" />
                </xsl:call-template>
              </fields>
            </foxml:xmlContent>
          </foxml:datastreamVersion>
        </foxml:datastream>                                               

          <foxml:datastream ID="DC" STATE="A" CONTROL_GROUP="X"
            VERSIONABLE="true">
            <foxml:datastreamVersion ID="DC.0"
              LABEL="Dublin Core Record for this object"
              CREATED="2013-11-06T21:24:13.236Z"
              MIMETYPE="text/xml"
              FORMAT_URI="http://www.openarchives.org/OAI/2.0/oai_dc/"
              SIZE="342">
              <foxml:xmlContent>
                <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"> 

                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'dc:title'" />
                    <xsl:with-param name="values" select="metadata/oai_dc:dc/dc:title" />
                  </xsl:call-template>

                  <xsl:for-each select="metadata/oai_dc:dc/dc:creator">
                    <xsl:call-template name="split-on">
                      <xsl:with-param name="tag" select="'dc:creator'" />
                      <xsl:with-param name="on" select="concat(., ';')" />
                    </xsl:call-template>
                  </xsl:for-each>

                  <xsl:for-each select="metadata/oai_dc:dc/dc:subject">
                    <xsl:call-template name="split-on">
                      <xsl:with-param name="tag" select="'dc:subject'" />
                      <xsl:with-param name="on" select="concat(., ';')" />
                    </xsl:call-template>
                  </xsl:for-each> 

                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'dc:description'" />
                    <xsl:with-param name="values" select="metadata/oai_dc:dc/dc:description" />
                  </xsl:call-template>

                  <xsl:for-each select="metadata/oai_dc:dc/dc:publisher">
                    <xsl:call-template name="split-on">
                      <xsl:with-param name="tag" select="'dc:publisher'" />
                      <xsl:with-param name="on" select="concat(., ';')" />
                    </xsl:call-template>
                  </xsl:for-each>

                  <xsl:for-each select="metadata/oai_dc:dc/dc:contributor">
                    <xsl:call-template name="split-on">
                      <xsl:with-param name="tag" select="'dc:contributor'" />
                      <xsl:with-param name="on" select="concat(., ';')" />
                    </xsl:call-template>
                  </xsl:for-each>

                  <xsl:for-each select="metadata/oai_dc:dc/dc:date">
                    <xsl:call-template name="split-on">
                      <xsl:with-param name="tag" select="'dc:date'" />
                      <xsl:with-param name="on" select="concat(., ';')" />
                    </xsl:call-template>
                  </xsl:for-each>

                  <xsl:for-each select="metadata/oai_dc:dc/dc:type">
                    <xsl:call-template name="split-on">
                      <xsl:with-param name="tag" select="'dc:type'" />
                      <xsl:with-param name="on" select="concat(., ';')" />
                    </xsl:call-template>
                  </xsl:for-each>

                  <xsl:for-each select="metadata/oai_dc:dc/dc:format">
                    <xsl:call-template name="split-on">
                      <xsl:with-param name="tag" select="'dc:format'" />
                      <xsl:with-param name="on" select="concat(., ';')" />
                    </xsl:call-template>
                  </xsl:for-each>

                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'dc:identifier'" />
                    <xsl:with-param name="values" select="metadata/oai_dc:dc/dc:identifier" />
                  </xsl:call-template>

                  <xsl:for-each select="metadata/oai_dc:dc/dc:source">
                    <xsl:call-template name="split-on">
                      <xsl:with-param name="tag" select="'dc:source'" />
                      <xsl:with-param name="on" select="concat(., ';')" />
                    </xsl:call-template>
                  </xsl:for-each>

                  <xsl:for-each select="metadata/oai_dc:dc/dc:language">
                    <xsl:call-template name="split-on">
                      <xsl:with-param name="tag" select="'dc:language'" />
                      <xsl:with-param name="on" select="concat(., ';')" />
                    </xsl:call-template>
                  </xsl:for-each>

                  <xsl:for-each select="metadata/oai_dc:dc/dc:relation">
                    <xsl:call-template name="split-on">
                      <xsl:with-param name="tag" select="'relation'" />
                      <xsl:with-param name="on" select="concat(., ';')" />
                    </xsl:call-template>
                  </xsl:for-each>

                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'dc:coverage'" />
                    <xsl:with-param name="values" select="metadata/oai_dc:dc/dc:coverage" />
                  </xsl:call-template>

                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'dc:rights'" />
                    <xsl:with-param name="values" select="metadata/oai_dc:dc/dc:rights" />
                  </xsl:call-template>

                </oai_dc:dc>
              </foxml:xmlContent>
            </foxml:datastreamVersion>

          </foxml:datastream>
          <foxml:datastream ID="descMetadata" STATE="A"
            CONTROL_GROUP="X" VERSIONABLE="true">
            <foxml:datastreamVersion ID="descMetadata.0"
              LABEL="" CREATED="2013-02-25T16:43:06.315Z"
              MIMETYPE="text/xml" SIZE="414">
              <foxml:xmlContent>
                <fields>
                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'title'" />
                    <xsl:with-param name="values" select="metadata/oai_dc:dc/dc:title" />
                  </xsl:call-template>

                  <xsl:for-each select="metadata/oai_dc:dc/dc:creator">
                  <xsl:call-template name="split-on">
                    <xsl:with-param name="tag" select="'creator'" />
                    <xsl:with-param name="on" select="concat(., ';')" />
                  </xsl:call-template>
                </xsl:for-each>

                  <xsl:for-each select="metadata/oai_dc:dc/dc:subject">
                    <xsl:call-template name="split-on">
                      <xsl:with-param name="tag" select="'subject'" />
                      <xsl:with-param name="on" select="concat(., ';')" />
                    </xsl:call-template>
                  </xsl:for-each> 

                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'description'" />
                    <xsl:with-param name="values" select="metadata/oai_dc:dc/dc:description" />
                  </xsl:call-template>

                  <xsl:for-each select="metadata/oai_dc:dc/dc:publisher">
                    <xsl:call-template name="split-on">
                      <xsl:with-param name="tag" select="'publisher'" />
                      <xsl:with-param name="on" select="concat(., ';')" />
                    </xsl:call-template>
                  </xsl:for-each>

                  <xsl:for-each select="metadata/oai_dc:dc/dc:contributor">
                    <xsl:call-template name="split-on">
                      <xsl:with-param name="tag" select="'contributor'" />
                      <xsl:with-param name="on" select="concat(., ';')" />
                    </xsl:call-template>
                  </xsl:for-each>

                  <xsl:for-each select="metadata/oai_dc:dc/dc:date">
                    <xsl:call-template name="split-on">
                      <xsl:with-param name="tag" select="'date'" />
                      <xsl:with-param name="on" select="concat(., ';')" />
                    </xsl:call-template>
                  </xsl:for-each>

                  <xsl:for-each select="metadata/oai_dc:dc/dc:type">
                    <xsl:call-template name="split-on">
                      <xsl:with-param name="tag" select="'type'" />
                      <xsl:with-param name="on" select="concat(., ';')" />
                    </xsl:call-template>
                  </xsl:for-each>

                  <xsl:for-each select="metadata/oai_dc:dc/dc:format">
                    <xsl:call-template name="split-on">
                      <xsl:with-param name="tag" select="'format'" />
                      <xsl:with-param name="on" select="concat(., ';')" />
                    </xsl:call-template>
                  </xsl:for-each>

                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'identifier'" />
                    <xsl:with-param name="values" select="metadata/oai_dc:dc/dc:identifier" />
                  </xsl:call-template>

                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'source'" />
                    <xsl:with-param name="values" select="metadata/oai_dc:dc/dc:source" />
                  </xsl:call-template>

                  <xsl:for-each select="metadata/oai_dc:dc/dc:language">
                    <xsl:call-template name="split-on">
                      <xsl:with-param name="tag" select="'language'" />
                      <xsl:with-param name="on" select="concat(., ';')" />
                    </xsl:call-template>
                  </xsl:for-each>

                  <xsl:for-each select="metadata/oai_dc:dc/dc:relation">
                    <xsl:call-template name="split-on">
                      <xsl:with-param name="tag" select="'relation'" />
                      <xsl:with-param name="on" select="concat(., ';')" />
                    </xsl:call-template>
                  </xsl:for-each>

                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'coverage'" />
                    <xsl:with-param name="values" select="metadata/oai_dc:dc/dc:coverage" />
                  </xsl:call-template>

                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'rights'" />
                    <xsl:with-param name="values" select="metadata/oai_dc:dc/dc:rights" />
                  </xsl:call-template>

                  <xsl:element name="contributing_institution">
                    <xsl:value-of select="$contributing_institution" />
                  </xsl:element>

                  <xsl:element name="intermediate_provider">
                    <xsl:value-of select="$intermediate_provider" />
                  </xsl:element>

                  <xsl:element name="set_spec">
                    <xsl:value-of select="$set_spec" />
                  </xsl:element>

                  <xsl:element name="collection_name">
                    <xsl:value-of select="$collection_name" />
                  </xsl:element>

                  <xsl:element name="partner">
                    <xsl:value-of select="$partner" />
                  </xsl:element>

                  <xsl:element name="common_repository_type">
                    <xsl:value-of select="$common_repository_type" />
                  </xsl:element>

                  <xsl:element name="endpoint_url">
                    <xsl:value-of select="$endpoint_url" />
                  </xsl:element>

                  <xsl:element name="provider_id_prefix">
                    <xsl:value-of select="$provider_id_prefix" />
                  </xsl:element>

                  <xsl:element name="identifier_pattern">
                    <xsl:value-of select="$identifier_pattern" />
                  </xsl:element>

                  <xsl:element name="identifier_token">
                    <xsl:value-of select="$identifier_token" />
                  </xsl:element>

                  <xsl:element name="rights_statement">
                    <xsl:value-of select="$rights_statement" />
                  </xsl:element>

                </fields>
              </foxml:xmlContent>
            </foxml:datastreamVersion>
          </foxml:datastream>
          
        </xsl:element>
      </exsl:document>
    
    </xsl:copy>
  </xsl:template>

  <xsl:template match="dc:subject[substring(., string-length()) = '.']|dc:type[substring(., string-length()) = '.']|dc:publisher[substring(., string-length()) = '.']|dc:language[substring(., string-length()) = '.']|dc:creator[substring(., string-length()) = '.']|dc:contributor[substring(., string-length()) = '.']|dc:date[substring(., string-length()) = '.']|dc:format[substring(., string-length()) = '.']|dc:source[substring(., string-length()) = '.']">
    <xsl:value-of select="substring(., 1, string-length(.) - 1)" />
  </xsl:template>

  <xsl:template match="dc:subject[substring(., string-length()) = ';']|dc:type[substring(., string-length()) = ';']|dc:publisher[substring(., string-length()) = ';']|dc:language[substring(., string-length()) = ';']|dc:creator[substring(., string-length()) = ';']|dc:contributor[substring(., string-length()) = ';']|dc:date[substring(., string-length()) = ';']|dc:format[substring(., string-length()) = ';']|dc:source[substring(., string-length()) = ';']">
    <xsl:value-of select="substring(., 1, string-length(.) - 1)" />
  </xsl:template>

  <xsl:template match="@*">
    <xsl:attribute name="{name()}">
      <xsl:value-of select="normalize-space()"/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template name="split-on">
    <xsl:param name="tag" />
    <xsl:param name="on" />
    <xsl:if test="$on != ''">
      <xsl:element name="{$tag}">
        <xsl:value-of select="substring-before(normalize-space($on), ';')" />
      </xsl:element> 
      <xsl:call-template name="split-on">
        <xsl:with-param name="on" select="substring-after(normalize-space($on), ';')" />
        <xsl:with-param name="tag" select="$tag" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="name-tag">
    <xsl:param name="tag" />
    <xsl:param name="values" />
    <xsl:for-each select="$values">
      <xsl:element name="{$tag}">
        <xsl:value-of select="normalize-space(.)" />
      </xsl:element>
    </xsl:for-each> 
  </xsl:template>

</xsl:stylesheet>
