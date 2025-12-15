<?xml version="1.0" encoding="UTF-8" ?>
<!--


    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/
	Developed by DSpace @ Lyncode <dspace@lyncode.com>

 -->
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:doc="http://www.lyncode.com/xoai"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	version="1.0">
	<xsl:output omit-xml-declaration="yes" method="xml" indent="yes" />

	<xsl:template match="/">
		<mods:mods xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xlink="http://www.w3.org/1999/xlink" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-1.xsd">
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='author']/doc:element/doc:field[@name='value']">
				<mods:name type="personal">
					<mods:namePart><xsl:value-of select="." /></mods:namePart>
					<xsl:if test="@affiliation">
					<mods:affiliation>
						<xsl:value-of select="@affiliation" />
					</mods:affiliation>
					</xsl:if>
					<mods:role>
						<mods:roleTerm type="text">author</mods:roleTerm>
					</mods:role>
					<xsl:if test="@orcid">
						<mods:nameIdentifier type="orcid">
							<xsl:value-of select="@orcid" />
						</mods:nameIdentifier>
					</xsl:if>
				</mods:name>
			</xsl:for-each>
			<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='accessioned']/doc:element/doc:field[@name='value']">
			<mods:extension>
				<mods:dateAvailable encoding="iso8601">
					<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='accessioned']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
				</mods:dateAvailable>
			</mods:extension>
			</xsl:if>
			<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='available']/doc:element/doc:field[@name='value']">
			<mods:extension>
				<mods:dateAccessioned encoding="iso8601">
					<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='available']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
				</mods:dateAccessioned>
			</mods:extension>
			</xsl:if>
			<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']">
			<mods:originInfo>
				<mods:dateIssued encoding="iso8601">
					<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
				</mods:dateIssued>
			</mods:originInfo>
			</xsl:if>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element/doc:element/doc:field[@name='value']">
			<mods:identifier>
				<xsl:attribute name="type">
					<xsl:value-of select="../../@name" />
				</xsl:attribute>
				<xsl:value-of select="." />
			</mods:identifier>
			</xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='abstract']/doc:element/doc:field[@name='value']">
				<mods:abstract><xsl:value-of select="." /></mods:abstract>
			</xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element/doc:element/doc:field[@name='value']">
			<mods:language>
				<mods:languageTerm type="code" authority="iso639-2b"><xsl:value-of select="." /></mods:languageTerm>
			</mods:language>
			</xsl:for-each>
			<!-- ========== ACCESS CONDITION ========== -->
			<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element[@name='none']/doc:field[@name='value']">
				<xsl:variable name="license_text" select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element[@name='none']/doc:field[@name='value']" />
				<xsl:variable name="license_url" select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element[@name='uri']/doc:element[1]/doc:field[@name='value']" />

				<mods:accessCondition type="use and reproduction">
					<xsl:if test="$license_url">
						<xsl:attribute name="xlink:href">
							<xsl:value-of select="$license_url" />
						</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="$license_text" />
				</mods:accessCondition>
			</xsl:if>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element/doc:field[@name='value']">
			<mods:subject>
				<xsl:if test="@vocabulary and @vocabulary != 'nd'">
					<xsl:attribute name="authority">
						<xsl:value-of select="@vocabulary" />
					</xsl:attribute>
				</xsl:if>
				<mods:topic><xsl:value-of select="." /></mods:topic>
			</mods:subject>
			</xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field[@name='value']">
			<mods:titleInfo>
				<mods:title><xsl:value-of select="." /></mods:title>
			</mods:titleInfo>
			</xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:field[@name='value']">
			<mods:genre authority="marcgt">
				<xsl:choose>
					<xsl:when test=". = 'review-article'">review</xsl:when>
					<xsl:when test=". = 'editorial'">editorial</xsl:when>
					<xsl:when test=". = 'case-report'">case reports</xsl:when>
					<xsl:when test=". = 'letter'">letter</xsl:when>
					<xsl:otherwise>article</xsl:otherwise>
				</xsl:choose>
			</mods:genre>
			</xsl:for-each>
			<!-- ========== TYPE OF RESOURCE ========== -->
			<mods:typeOfResource>text</mods:typeOfResource>
			<!-- ========== RELATED ITEM (HOST JOURNAL) ========== -->
		<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='ispartof']/doc:element/doc:field[@name='value']">
		<mods:relatedItem type="host">
			<!-- Título do periódico -->
			<mods:titleInfo>
				<mods:title>
					<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='ispartof']/doc:element/doc:field[@name='value']" />
				</mods:title>
			</mods:titleInfo>

			<!-- ISSN print -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='issn']/doc:element/doc:field[@name='value']">
			<mods:identifier type="issn">
				<xsl:value-of select="." />
			</mods:identifier>
			</xsl:for-each>

			<!-- ISSN eletrônico -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='eissn']/doc:element/doc:field[@name='value']">
			<mods:identifier type="eissn">
				<xsl:value-of select="." />
			</mods:identifier>
			</xsl:for-each>

			<!-- Publisher (editora) -->
			<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element[@name='none']/doc:field[@name='value']">
			<mods:originInfo>
				<mods:publisher>
					<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element[@name='none']/doc:field[@name='value']" />
				</mods:publisher>
			</mods:originInfo>
			</xsl:if>

			<!-- PART: Volume, Issue, Pages -->
			<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='citation']">
			<mods:part>
				<!-- Volume -->
				<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='citation']/doc:element[@name='volume']/doc:element/doc:field[@name='value']">
				<mods:detail type="volume">
					<mods:number>
						<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='citation']/doc:element[@name='volume']/doc:element/doc:field[@name='value']" />
					</mods:number>
				</mods:detail>
				</xsl:if>

				<!-- Issue/Number -->
				<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='citation']/doc:element[@name='issue']/doc:element/doc:field[@name='value']">
				<mods:detail type="issue">
					<mods:number>
						<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='citation']/doc:element[@name='issue']/doc:element/doc:field[@name='value']" />
					</mods:number>
				</mods:detail>
				</xsl:if>

				<!-- Pages (extent) -->
				<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='citation']/doc:element[@name='spage']/doc:element/doc:field[@name='value']">
				<mods:extent unit="page">
					<mods:start>
						<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='citation']/doc:element[@name='spage']/doc:element/doc:field[@name='value']" />
					</mods:start>
					<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='citation']/doc:element[@name='epage']/doc:element/doc:field[@name='value']">
					<mods:end>
						<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='citation']/doc:element[@name='epage']/doc:element/doc:field[@name='value']" />
					</mods:end>
					</xsl:if>
				</mods:extent>
				</xsl:if>

				<!-- Date (ano de publicação) -->
				<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']">
				<mods:date>
					<xsl:value-of select="substring(doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value'], 1, 4)" />
				</mods:date>
				</xsl:if>
			</mods:part>
			</xsl:if>
		</mods:relatedItem>
		</xsl:if>
			<!-- ========== LOCATION ========== -->
			<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='uri']/doc:element/doc:field[@name='value']">
			<mods:location>
				<mods:url usage="primary display" access="object in context">
					<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='uri']/doc:element[1]/doc:field[@name='value']" />
				</mods:url>
				<mods:physicalLocation>SciELO Network</mods:physicalLocation>
			</mods:location>
			</xsl:if>
			<!-- ========== FUNDING NOTE ========== -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='sponsorship']/doc:element/doc:field[@name='value']">
			<mods:note type="funding">
				<xsl:value-of select="." />
			</mods:note>
			</xsl:for-each>
		</mods:mods>
	</xsl:template>
</xsl:stylesheet>