<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns:foxml="info:fedora/fedora-system:def/foxml#"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:exsl="http://exslt.org/common"
  extension-element-prefixes="exsl">

  <xsl:variable name="converted_path">
    <xsl:value-of select="records/manifest/converted_foxml_directory" />
  </xsl:variable>

  <xsl:variable name="contributing_institution">
    <xsl:value-of select="records/manifest/contributing_institution" />
  </xsl:variable>

  <xsl:variable name="collection_name">
    <xsl:value-of select="records/manifest/collection_name" />
  </xsl:variable>

  <xsl:variable name="partner">
    <xsl:value-of select="records/manifest/partner" />
  </xsl:variable>

  <xsl:output method="xml" indent="yes"/>
      <xsl:template match="records/metadata/oai_dc:dc">
        <xsl:copy>
      <xsl:variable name="apos">'</xsl:variable>
      <xsl:variable name="pid_raw">
        <xsl:value-of select="dc:identifier" />
      </xsl:variable>
      
      <xsl:variable name="pid_intermed">
        <xsl:value-of select="substring(translate($pid_raw, ' /:httpwww.,()-_', ''), 1, 59)"/>
      </xsl:variable>

      <xsl:variable name="pid">
        <xsl:value-of select="substring(translate($pid_intermed, $apos, ''), 1, 59)"/>
      </xsl:variable>

      <exsl:document method="xml" href="{$converted_path}/file_{$pid}.foxml.xml">        
        <xsl:element name="foxml:digitalObject"
          xmlns:foxml="info:fedora/fedora-system:def/foxml#"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
          <xsl:attribute name="VERSION">
            <xsl:value-of select="1.1"/>
          </xsl:attribute>
          <xsl:attribute name="xsi:schemaLocation">info:fedora/fedora-system:def/foxml# http://www.fedora.info/definitions/1/0/foxml1-1.xsd</xsl:attribute>
          <foxml:objectProperties>
            <foxml:property
              NAME="info:fedora/fedora-system:def/model#state"
              VALUE="Active"/>
            <foxml:property
              NAME="info:fedora/fedora-system:def/model#label"
              VALUE="FOXML Reference Example"/>
            <foxml:property
              NAME="info:fedora/fedora-system:def/model#ownerId"
              VALUE=""/>
            <foxml:property
              NAME="info:fedora/fedora-system:def/model#createdDate"
              VALUE="2013-11-06T21:24:13.236Z"/>
            <foxml:property
              NAME="info:fedora/fedora-system:def/view#lastModifiedDate"
              VALUE="2013-11-06T21:24:13.236Z"/>
          </foxml:objectProperties>
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
                    <xsl:with-param name="values" select="dc:title" />
                  </xsl:call-template>

                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'dc:creator'" />
                    <xsl:with-param name="values" select="dc:creator" />
                  </xsl:call-template>

                  <xsl:call-template name="split-subjects">
                    <xsl:with-param name="tag" select="'dc:subject'" />
                    <xsl:with-param name="subjects" select="concat(dc:subject, ';')" />
                  </xsl:call-template>

                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'dc:description'" />
                    <xsl:with-param name="values" select="dc:description" />
                  </xsl:call-template>

                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'dc:publisher'" />
                    <xsl:with-param name="values" select="dc:publisher" />
                  </xsl:call-template>

                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'dc:contributor'" />
                    <xsl:with-param name="values" select="dc:contributor" />
                  </xsl:call-template>

                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'dc:date'" />
                    <xsl:with-param name="values" select="dc:date" />
                  </xsl:call-template>

                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'dc:type'" />
                    <xsl:with-param name="values" select="dc:type" />
                  </xsl:call-template>

                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'dc:format'" />
                    <xsl:with-param name="values" select="dc:format" />
                  </xsl:call-template>

                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'dc:identifier'" />
                    <xsl:with-param name="values" select="dc:identifier" />
                  </xsl:call-template>

                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'dc:source'" />
                    <xsl:with-param name="values" select="dc:source" />
                  </xsl:call-template>

                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'dc:language'" />
                    <xsl:with-param name="values" select="dc:language" />
                  </xsl:call-template>

                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'dc:relation'" />
                    <xsl:with-param name="values" select="dc:relation" />
                  </xsl:call-template>

                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'dc:coverage'" />
                    <xsl:with-param name="values" select="dc:coverage" />
                  </xsl:call-template>

                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'dc:rights'" />
                    <xsl:with-param name="values" select="dc:rights" />
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
                    <xsl:with-param name="values" select="dc:title" />
                  </xsl:call-template>

                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'creator'" />
                    <xsl:with-param name="values" select="dc:creator" />
                  </xsl:call-template>

                  <xsl:call-template name="split-subjects">
                    <xsl:with-param name="tag" select="'subject'" />
                    <xsl:with-param name="subjects" select="concat(dc:subject, ';')" />
                  </xsl:call-template>

                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'description'" />
                    <xsl:with-param name="values" select="dc:description" />
                  </xsl:call-template>

                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'publisher'" />
                    <xsl:with-param name="values" select="dc:publisher" />
                  </xsl:call-template>

                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'contributor'" />
                    <xsl:with-param name="values" select="dc:contributor" />
                  </xsl:call-template>

                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'date'" />
                    <xsl:with-param name="values" select="dc:date" />
                  </xsl:call-template>

                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'type'" />
                    <xsl:with-param name="values" select="dc:type" />
                  </xsl:call-template>

                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'format'" />
                    <xsl:with-param name="values" select="dc:format" />
                  </xsl:call-template>

                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'identifier'" />
                    <xsl:with-param name="values" select="dc:identifier" />
                  </xsl:call-template>

                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'source'" />
                    <xsl:with-param name="values" select="dc:source" />
                  </xsl:call-template>

                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'language'" />
                    <xsl:with-param name="values" select="dc:language" />
                  </xsl:call-template>

                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'relation'" />
                    <xsl:with-param name="values" select="dc:relation" />
                  </xsl:call-template>

                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'coverage'" />
                    <xsl:with-param name="values" select="dc:coverage" />
                  </xsl:call-template>

                  <xsl:call-template name="name-tag">
                    <xsl:with-param name="tag" select="'rights'" />
                    <xsl:with-param name="values" select="dc:rights" />
                  </xsl:call-template>

                  <xsl:element name="contributing_institution">
                    <xsl:value-of select="$contributing_institution" />
                  </xsl:element>

                  <xsl:element name="collection_name">
                    <xsl:value-of select="$collection_name" />
                  </xsl:element>

                  <xsl:element name="partner">
                    <xsl:value-of select="$partner" />
                  </xsl:element>

                </fields>
              </foxml:xmlContent>
            </foxml:datastreamVersion>
          </foxml:datastream>
          
        </xsl:element>
      </exsl:document>
    
    </xsl:copy>
  </xsl:template>

  <xsl:template match="dc:subject[substring(., string-length()) = '.']|dc:type[substring(., string-length()) = '.']|dc:publisher[substring(., string-length()) = '.']|dc:language[substring(., string-length()) = '.']">
    <xsl:value-of select="substring(., 1, string-length(.) - 1)" />
  </xsl:template>

  <xsl:template match="dc:subject[substring(., string-length()) = ';']|dc:type[substring(., string-length()) = ';']|dc:publisher[substring(., string-length()) = ';']|dc:language[substring(., string-length()) = ';']">
    <xsl:value-of select="substring(., 1, string-length(.) - 1)" />
  </xsl:template>

  <xsl:template match="@*">
    <xsl:attribute name="{name()}">
      <xsl:value-of select="normalize-space()"/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template name="split-subjects">
    <xsl:param name="tag" />
    <xsl:param name="subjects" />
    <xsl:if test="$subjects != ''">
      <xsl:element name="{$tag}">
        <xsl:value-of select="substring-before(normalize-space($subjects), ';')" />
      </xsl:element> 
      <xsl:call-template name="split-subjects">
        <xsl:with-param name="subjects" select="substring-after(normalize-space($subjects), ';')" />
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
