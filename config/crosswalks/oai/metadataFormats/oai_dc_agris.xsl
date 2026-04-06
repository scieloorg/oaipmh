<?xml version="1.0" encoding="UTF-8"?>
<!--
    Crosswalk: XOAI (DSpace/Lyncode) → AGRIS Application Profile (ags:resource)

    Corrigido em conformidade com:
      - AGRIS AP Specification of Elements:
          https://www.fao.org/4/ae909e/ae909e05.htm
      - AGRIS AP Technical Guidelines (XML encoding):
          https://www.fao.org/docrep/008/ae908e/ae908e00.htm
      - DTD normativa:
          http://purl.org/agmes/agrisap/dtd/

    Alterações em relação à versão original (DSpace @ Lyncode):
      C1 - version="1.0" → version="2.0"  (distinct-values/matches/tokenize são XPath 2.0)
      C2 - ags:ARN adicionado ao elemento raiz ags:resource (obrigatório pelo padrão)
      C3 - Namespace agls duplicado e xmlns:xsl redundante removidos de ags:resource
      C4 - dc.title.* mapeado para dcterms:alternative (não dc:title)
      C5 - dc.contributor.author passa a usar ags:creatorPersonal + deduplicação por distinct-values()
      C6 - dc.subject usa ags:subjectThesaurus quando vocabulário controlado está indicado
      C7 - dc.description filtra apenas sub-elemento 'abstract'; sponsorship e provenance excluídos
      C8 - dc.date filtra apenas sub-elemento 'issued'; datas internas (accessioned/available) excluídas
      C9 - dc.identifier corrigido: sem auto-aninhamento; usa ags:identifier com scheme por tipo
      C10 - dc.language corrigido: scheme inválido em dc:language substituído por ags:languageCode
      C11 - dc.publisher (plano) passa a usar ags:publisherName consistentemente
      C12 - Bloco <about> removido do conteúdo de metadados (deve ser gerenciado pelo framework
            OAI-PMH no nível <record>, não pelo XSLT de conteúdo)
-->

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:doc="http://www.lyncode.com/xoai"
    xmlns:ags="http://purl.org/agmes/1.1/"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:agls="http://www.naa.gov.au/recordkeeping/gov_online/agls/1.2"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    version="2.0">

    <xsl:output omit-xml-declaration="yes" method="xml" indent="yes" />

    <xsl:template match="/">

        <!-- C2: ags:ARN obrigatório — usa o identificador interno do registro como valor -->
        <ags:resource
            xmlns:ags="http://purl.org/agmes/1.1/"
            xmlns:dc="http://purl.org/dc/elements/1.1/"
            xmlns:agls="http://www.naa.gov.au/recordkeeping/gov_online/agls/1.2"
            xmlns:dcterms="http://purl.org/dc/terms/"
            ags:ARN="{doc:metadata/doc:element[@name='others']/doc:field[@name='identifier']}">

            <!-- ================================================================ -->
            <!-- dc:title                                                         -->
            <!-- AGRIS AP 4.1 — https://www.fao.org/4/ae909e/ae909e05.htm        -->
            <!-- ================================================================ -->

            <!-- dc.title — título principal; xml:lang adicionado quando disponível -->
            <xsl:for-each
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field[@name='value']">
                <dc:title>
                    <xsl:if test="../@name != 'none'">
                        <xsl:attribute name="xml:lang">
                            <xsl:value-of select="../@name" />
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="." />
                </dc:title>
            </xsl:for-each>

            <!-- C4: dc.title.* — títulos alternativos mapeados para dcterms:alternative -->
            <xsl:for-each
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:element/doc:field[@name='value']">
                <dcterms:alternative>
                    <xsl:value-of select="." />
                </dcterms:alternative>
            </xsl:for-each>

            <!-- ================================================================ -->
            <!-- dc:creator                                                        -->
            <!-- AGRIS AP 4.2 — creatorPersonal obrigatório para autores pessoais -->
            <!-- Formato: Sobrenome, Nome  (conforme especificação AGRIS AP 4.2)  -->
            <!-- ================================================================ -->

            <!-- dc.creator — autores pessoais explícitos -->
            <xsl:for-each
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='creator']/doc:element/doc:field[@name='value']">
                <dc:creator>
                    <ags:creatorPersonal><xsl:value-of select="." /></ags:creatorPersonal>
                </dc:creator>
            </xsl:for-each>

            <!-- C5: dc.contributor.author → dc:creator com ags:creatorPersonal + deduplicação -->
            <!-- distinct-values() elimina entradas repetidas por afiliação múltipla no Solr  -->
            <xsl:for-each
                select="distinct-values(
                    doc:metadata/doc:element[@name='dc']
                        /doc:element[@name='contributor']
                        /doc:element[@name='author']
                        /doc:element/doc:field[@name='value'])">
                <dc:creator>
                    <ags:creatorPersonal><xsl:value-of select="." /></ags:creatorPersonal>
                </dc:creator>
            </xsl:for-each>

            <xsl:for-each
                select="distinct-values(
                    doc:metadata/doc:element[@name='dc']
                        /doc:element[@name='contributor']
                        /doc:element[@name='author']
                        /doc:field[@name='value'])">
                <dc:creator>
                    <ags:creatorPersonal><xsl:value-of select="." /></ags:creatorPersonal>
                </dc:creator>
            </xsl:for-each>

            <!-- ================================================================ -->
            <!-- dc:contributor                                                    -->
            <!-- Exclui campos de ID/Lattes e autores (já mapeados como creator)  -->
            <!-- ================================================================ -->

            <!-- dc.contributor.* (!author e campos de controle interno) -->
            <xsl:variable name="excluidos"
                select="('author','authorID','authorLattes',
                         'advisor1ID','advisor1Lattes',
                         'advisor2ID','advisor2Lattes',
                         'advisor-co1ID','advisor-co1Lattes',
                         'advisor-co2ID','advisor-co2Lattes',
                         'referee1ID','referee1Lattes',
                         'referee2ID','referee2Lattes',
                         'referee3ID','referee3Lattes',
                         'referee4ID','referee4Lattes',
                         'referee5ID','referee5Lattes')" />

            <xsl:for-each
                select="doc:metadata/doc:element[@name='dc']
                    /doc:element[@name='contributor']
                    /doc:element[not(@name = $excluidos)]
                    /doc:element/doc:field[@name='value']">
                <dc:contributor>
                    <xsl:value-of select="." />
                </dc:contributor>
            </xsl:for-each>

            <xsl:for-each
                select="doc:metadata/doc:element[@name='dc']
                    /doc:element[@name='contributor']
                    /doc:element[not(@name = $excluidos)]
                    /doc:field[@name='value']">
                <dc:contributor>
                    <xsl:value-of select="." />
                </dc:contributor>
            </xsl:for-each>

            <!-- ================================================================ -->
            <!-- dc:subject                                                        -->
            <!-- AGRIS AP 4.5 — usa ags:subjectThesaurus quando vocabulário       -->
            <!-- controlado está declarado; texto livre caso contrário             -->
            <!-- ================================================================ -->

            <!-- C6: dc.subject — com detecção de vocabulário controlado -->
            <xsl:for-each
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element/doc:field[@name='value']">
                <dc:subject>
                    <xsl:choose>
                        <xsl:when test="@vocabulary and @vocabulary != 'nd'">
                            <ags:subjectThesaurus scheme="ags:{upper-case(@vocabulary)}">
                                <xsl:value-of select="." />
                            </ags:subjectThesaurus>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="." />
                        </xsl:otherwise>
                    </xsl:choose>
                </dc:subject>
            </xsl:for-each>

            <!-- dc.subject.* -->
            <xsl:for-each
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element/doc:element/doc:field[@name='value']">
                <dc:subject>
                    <xsl:value-of select="." />
                </dc:subject>
            </xsl:for-each>

            <!-- ================================================================ -->
            <!-- dc:description                                                    -->
            <!-- AGRIS AP 4.6 — apenas resumo (abstract); sponsorship e           -->
            <!-- provenance excluídos explicitamente                               -->
            <!-- ================================================================ -->

            <!-- C7: dc.description.abstract — único sub-elemento emitido -->
            <xsl:for-each
                select="doc:metadata/doc:element[@name='dc']
                    /doc:element[@name='description']
                    /doc:element[@name='abstract']
                    /doc:element/doc:field[@name='value']">
                <dc:description>
                    <dcterms:abstract><xsl:value-of select="." /></dcterms:abstract>
                </dc:description>
            </xsl:for-each>

            <!-- dc.description sem qualificador (lang=none) — texto simples -->
            <xsl:for-each
                select="doc:metadata/doc:element[@name='dc']
                    /doc:element[@name='description']
                    /doc:element[@name='none']
                    /doc:field[@name='value']">
                <dc:description>
                    <xsl:value-of select="." />
                </dc:description>
            </xsl:for-each>

            <!-- ================================================================ -->
            <!-- dc:date                                                           -->
            <!-- AGRIS AP 4.7 — apenas dcterms:dateIssued; datas internas         -->
            <!-- (accessioned, available) não devem ser expostas externamente      -->
            <!-- ================================================================ -->

            <!-- C8: dc.date.issued — único sub-elemento emitido -->
            <xsl:for-each
                select="doc:metadata/doc:element[@name='dc']
                    /doc:element[@name='date']
                    /doc:element[@name='issued']
                    /doc:element/doc:field[@name='value']">
                <dc:date>
                    <dcterms:dateIssued><xsl:value-of select="." /></dcterms:dateIssued>
                </dc:date>
            </xsl:for-each>

            <!-- ================================================================ -->
            <!-- dc:type                                                           -->
            <!-- ================================================================ -->

            <!-- dc.type -->
            <xsl:for-each
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:field[@name='value']">
                <dc:type>
                    <xsl:value-of select="." />
                </dc:type>
            </xsl:for-each>

            <!-- dc.type.* -->
            <xsl:for-each
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:element/doc:field[@name='value']">
                <dc:type>
                    <xsl:value-of select="." />
                </dc:type>
            </xsl:for-each>

            <!-- ================================================================ -->
            <!-- dc:identifier                                                     -->
            <!-- AGRIS AP 4.8 — ags:identifier com scheme obrigatório;            -->
            <!-- identificadores internos (sub-elemento 'none') não são expostos  -->
            <!-- ================================================================ -->

            <!-- C9: dc.identifier.doi -->
            <xsl:for-each
                select="doc:metadata/doc:element[@name='dc']
                    /doc:element[@name='identifier']
                    /doc:element[@name='doi']
                    /doc:element/doc:field[@name='value']">
                <dc:identifier>
                    <ags:identifier scheme="ags:DOI"><xsl:value-of select="." /></ags:identifier>
                </dc:identifier>
            </xsl:for-each>

            <!-- C9: dc.identifier.uri -->
            <xsl:for-each
                select="doc:metadata/doc:element[@name='dc']
                    /doc:element[@name='identifier']
                    /doc:element[@name='uri']
                    /doc:element/doc:field[@name='value']">
                <dc:identifier>
                    <ags:identifier scheme="dcterms:URI"><xsl:value-of select="." /></ags:identifier>
                </dc:identifier>
            </xsl:for-each>

            <!-- C9: dc.identifier.issn -->
            <xsl:for-each
                select="doc:metadata/doc:element[@name='dc']
                    /doc:element[@name='identifier']
                    /doc:element[@name='issn']
                    /doc:element/doc:field[@name='value']">
                <dc:identifier>
                    <ags:identifier scheme="ags:ISSN"><xsl:value-of select="." /></ags:identifier>
                </dc:identifier>
            </xsl:for-each>

            <!-- C9: dc.identifier.isbn -->
            <xsl:for-each
                select="doc:metadata/doc:element[@name='dc']
                    /doc:element[@name='identifier']
                    /doc:element[@name='isbn']
                    /doc:element/doc:field[@name='value']">
                <dc:identifier>
                    <ags:identifier scheme="ags:ISBN"><xsl:value-of select="." /></ags:identifier>
                </dc:identifier>
            </xsl:for-each>

            <!-- C9: dc.identifier.* — demais tipos nomeados (exceto 'none', 'doi', 'uri', 'issn', 'isbn') -->
            <xsl:for-each
                select="doc:metadata/doc:element[@name='dc']
                    /doc:element[@name='identifier']
                    /doc:element[not(@name=('none','doi','uri','issn','isbn'))]
                    /doc:element/doc:field[@name='value']">
                <dc:identifier>
                    <ags:identifier scheme="ags:{upper-case(../@name)}">
                        <xsl:value-of select="." />
                    </ags:identifier>
                </dc:identifier>
            </xsl:for-each>

            <!-- ================================================================ -->
            <!-- dc:language                                                       -->
            <!-- AGRIS AP 4.9 — scheme declarado via ags:languageCode,            -->
            <!-- não como atributo em dc:language (DC não suporta atributos)      -->
            <!-- ================================================================ -->

            <!-- C10: dc.language -->
            <xsl:for-each
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element/doc:field[@name='value']">
                <dc:language>
                    <ags:languageCode scheme="ags:ISO639-1"><xsl:value-of select="." /></ags:languageCode>
                </dc:language>
            </xsl:for-each>

            <!-- C10: dc.language.* -->
            <xsl:for-each
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element/doc:element/doc:field[@name='value']">
                <dc:language>
                    <ags:languageCode scheme="ags:ISO639-1"><xsl:value-of select="." /></ags:languageCode>
                </dc:language>
            </xsl:for-each>

            <!-- ================================================================ -->
            <!-- dc:relation                                                       -->
            <!-- ================================================================ -->

            <!-- dc.relation -->
            <xsl:for-each
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element/doc:field[@name='value']">
                <dc:relation>
                    <xsl:value-of select="." />
                </dc:relation>
            </xsl:for-each>

            <!-- dc.relation.* -->
            <xsl:for-each
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element/doc:element/doc:field[@name='value']">
                <dc:relation>
                    <xsl:value-of select="." />
                </dc:relation>
            </xsl:for-each>

            <!-- ================================================================ -->
            <!-- dc:rights                                                         -->
            <!-- ================================================================ -->

            <!-- dc.rights -->
            <xsl:for-each
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element/doc:field[@name='value']">
                <dc:rights>
                    <xsl:value-of select="." />
                </dc:rights>
            </xsl:for-each>

            <!-- dc.rights.* -->
            <xsl:for-each
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element/doc:element/doc:field[@name='value']">
                <dc:rights>
                    <xsl:value-of select="." />
                </dc:rights>
            </xsl:for-each>

            <!-- ================================================================ -->
            <!-- dc:format                                                         -->
            <!-- ================================================================ -->

            <!-- dc.format -->
            <xsl:for-each
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='format']/doc:element/doc:field[@name='value']">
                <dc:format>
                    <dcterms:medium><xsl:value-of select="." /></dcterms:medium>
                </dc:format>
            </xsl:for-each>

            <!-- dc.format.* -->
            <xsl:for-each
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='format']/doc:element/doc:element/doc:field[@name='value']">
                <dc:format>
                    <xsl:value-of select="." />
                </dc:format>
            </xsl:for-each>

            <!-- formato do bitstream (DSpace) -->
            <xsl:for-each
                select="doc:metadata/doc:element[@name='bitstreams']/doc:element[@name='bitstream']/doc:field[@name='format']">
                <dc:format>
                    <xsl:value-of select="." />
                </dc:format>
            </xsl:for-each>

            <!-- ================================================================ -->
            <!-- dc:coverage                                                       -->
            <!-- ================================================================ -->

            <!-- dc.coverage -->
            <xsl:for-each
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='coverage']/doc:element/doc:field[@name='value']">
                <dc:coverage>
                    <xsl:value-of select="." />
                </dc:coverage>
            </xsl:for-each>

            <!-- dc.coverage.* -->
            <xsl:for-each
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='coverage']/doc:element/doc:element/doc:field[@name='value']">
                <dc:coverage>
                    <xsl:value-of select="." />
                </dc:coverage>
            </xsl:for-each>

            <!-- ================================================================ -->
            <!-- dc:publisher                                                      -->
            <!-- AGRIS AP 4.4 — ags:publisherName obrigatório                    -->
            <!-- ================================================================ -->

            <!-- C11: dc.publisher — agora consistente com ags:publisherName -->
            <xsl:for-each
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element/doc:field[@name='value']">
                <dc:publisher>
                    <ags:publisherName><xsl:value-of select="." /></ags:publisherName>
                </dc:publisher>
            </xsl:for-each>

            <!-- dc.publisher.* -->
            <xsl:for-each
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element/doc:element/doc:field[@name='value']">
                <dc:publisher>
                    <ags:publisherName><xsl:value-of select="." /></ags:publisherName>
                </dc:publisher>
            </xsl:for-each>

            <!-- ================================================================ -->
            <!-- dc:source                                                         -->
            <!-- ================================================================ -->

            <!-- dc.source -->
            <xsl:for-each
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']/doc:element/doc:field[@name='value']">
                <dc:source>
                    <xsl:value-of select="." />
                </dc:source>
            </xsl:for-each>

            <!-- dc.source.* -->
            <xsl:for-each
                select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']/doc:element/doc:element/doc:field[@name='value']">
                <dc:source>
                    <xsl:value-of select="." />
                </dc:source>
            </xsl:for-each>

            <!--
                C12: Bloco <about><provenance> REMOVIDO deste XSLT.

                O elemento <about> pertence ao nível <record> do protocolo OAI-PMH,
                como irmão de <metadata>, nunca como filho do conteúdo de metadados.
                Sua geração deve ser configurada no framework XOAI (lareferencia-oai-pmh)
                por meio do mecanismo de provenance nativo do XOAI, não via XSLT de crosswalk.

                Referência OAI-PMH: https://www.openarchives.org/OAI/openarchivesprotocol.html#Record
            -->

        </ags:resource>
    </xsl:template>

</xsl:stylesheet>
