<?xml version="1.0" encoding="UTF-8"?>

<!--
    xml2json.xsl - transform Bison XML Report into json text.

    Copyright (C) 2007-2015, 2018 Free Software Foundation, Inc.

    This file is part of Bison, the GNU Compiler Compiler.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

    Written by Wojciech Polak <polak@gnu.org>.
  -->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:bison="http://www.gnu.org/software/bison/">

    <xsl:import href="bison.xsl"/>
    <xsl:output method="text" encoding="UTF-8" indent="no"/>

    <xsl:template match="/">
        <xsl:apply-templates select="bison-xml-report"/>
    </xsl:template>

    <xsl:template match="bison-xml-report">
        <xsl:text>{ "grammar" : [</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:apply-templates select="grammar"/>
        <xsl:text>] }</xsl:text>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

    <xsl:template match="grammar">
        <xsl:call-template name="style-rule-set">
            <xsl:with-param
                    name="rule-set" select="rules/rule[@usefulness!='']"
            />
        </xsl:call-template>
        <xsl:apply-templates select="terminals"/>
    </xsl:template>

    <xsl:template name="style-rule-set">
        <xsl:param name="rule-set"/>
        <xsl:for-each select="$rule-set">
            <xsl:apply-templates select=".">
            </xsl:apply-templates>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="grammar/terminals">
        <xsl:apply-templates select="terminal"/>
    </xsl:template>

    <xsl:template match="terminal">
        <xsl:text>["</xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:text>"],&#10;</xsl:text>
    </xsl:template>

    <xsl:template match="rule">

        <!-- LHS -->
        <xsl:text>[</xsl:text>
        <xsl:text>"</xsl:text>
        <xsl:value-of select="lhs"/>
        <xsl:text>",</xsl:text>

        <!-- RHS -->
        <xsl:for-each select="rhs/*">
            <xsl:text>"</xsl:text>
            <xsl:apply-templates select="."/>
            <xsl:text>"</xsl:text>

            <xsl:choose>
                <xsl:when test="last()=position()">
                    <xsl:text>],&#10;</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>,</xsl:text>
                </xsl:otherwise>
            </xsl:choose>

        </xsl:for-each>

    </xsl:template>

    <xsl:template match="symbol">
        <xsl:value-of select="."/>
    </xsl:template>

    <xsl:template match="empty">
        <xsl:text>%empty</xsl:text>
    </xsl:template>

</xsl:stylesheet>
