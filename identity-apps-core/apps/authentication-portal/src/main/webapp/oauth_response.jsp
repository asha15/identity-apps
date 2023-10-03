<%--
~    Copyright (c) 2022, WSO2 Inc. (http://www.wso2.com). All Rights Reserved.
~
~    This software is the property of WSO2 Inc. and its suppliers, if any.
~    Dissemination of any information or reproduction of any material contained
~    herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
~    You may not alter or remove any copyright or other notice from copies of this content."
--%>

<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="org.apache.commons.text.StringEscapeUtils" %>
<%@ page import="org.wso2.carbon.identity.application.authentication.endpoint.util.AuthenticationEndpointUtil" %>

<%
    String USER_TENANT_DOMAIN = "userTenantDomain";
    String USER_TENANT_DOMAIN_SHORT = "ut";
    String SERVICE_PROVIDER_NAME = "serviceProvider";
    String SERVICE_PROVIDER_NAME_SHORT = "sp";

    request.setAttribute(USER_TENANT_DOMAIN_SHORT, request.getAttribute(USER_TENANT_DOMAIN));
    request.setAttribute(SERVICE_PROVIDER_NAME_SHORT, request.getAttribute(SERVICE_PROVIDER_NAME));
    // The `request` object contains the tenantDomain, which can be directly provided to the init-url.jsp code.
%>

<%-- Include tenant context --%>
<jsp:directive.include file="includes/init-url.jsp"/>

<%-- Branding Preferences --%>
<jsp:directive.include file="includes/branding-preferences.jsp"/>

<%-- Localization --%>
<jsp:directive.include file="includes/localize.jsp" />

<html>

<head>
    <title><%= productName %></title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <style type="text/css">
        @import url('https://fonts.googleapis.com/css2?family=Montserrat&display=swap');

        @font-face {
            font-family: 'Montserrat', sans-serif;
            font-style: normal;
            font-weight: 400;
            src: local('Montserrat'),
                local('Montserrat'),
                url('https://fonts.googleapis.com/css2?family=Montserrat&display=swap') format('Roboto');
        }

        .pre-loader-logo {
            margin-top: 41px;
            border-style: none;
        }

        .content-loader {
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            user-select: none;
        }

        .content-loader .ui.loader {
            display: block;
            position: relative;
            margin-top: 10px;
            margin-bottom: 25px;
        }

        @keyframes loader {
            0% {
                transform: rotate(0)
            }

            to {
                transform: rotate(1turn)
            }
        }

        .content-loader .ui.loader:before {
            content: "";
            display: block;
            height: 26px;
            width: 26px;
            border: .2em solid rgba(0,0,0,.1);
            border-radius: 500rem;
        }

        .content-loader .ui.loader:after {
            content: "";
            position: absolute;
            height: 26px;
            width: 26px;
            border-color: #767676 transparent transparent !important;
            border: .2em solid transparent;
            animation: loader .6s linear;
            animation-iteration-count: infinite;
            border-radius: 500rem;
            box-shadow: 0 0 0 1px transparent;
            top: 0;
            left: 0;
        } 

        .trifacta-pre-loader {
            margin-top: 41px;
        }

        svg #_1 {
            animation-name: alert-success;
            animation-duration: 3s;
            position: relative;
            animation-delay: 0s;
            animation-iteration-count: infinite;

        }

        svg #_2 {
            animation-name: alert-success;
            animation-duration: 3s;
            position: relative;
            animation-delay: 1s;
            animation-iteration-count: infinite;

        }

        svg #_3 {
            animation-name: alert-success;
            animation-duration: 3s;
            position: relative;
            animation-delay: 2s;
            animation-iteration-count: infinite;

        }

        @keyframes alert-success {
            0% {
                opacity: 1;
            }

            100% {
                opacity: 0;
            }
        }

        .login-portal.layout {
            background: #f5f6f6;
            height: 100%;
            flex-direction: column;
            display: flex;
            margin: unset;
        }

        .login-portal {
            font-family: Montserrat, -apple-system, BlinkMacSystemFont, Segoe UI, HelveticaNeue-Light, Ubuntu, Droid Sans, sans-serif;
        }

        .login-portal.layout .page-wrapper {
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        .login-portal.layout .center-segment {
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .login-portal.layout .center-segment {
            flex-shrink: 0;
            margin: auto;
            display: flex;
            align-items: center;
        }

        .text-center {
            text-align: center !important;
        }

        .message-description {
            color: #999ea2;
            font-size: 17px;
        }

        p:last-child {
            margin-bottom: 0;
        }

        p {
            margin: 0 0 1em;
            line-height: 1.4285em;
        }

        .message-header {
            font-weight: 300 !important;
            font-family: Montserrat, sans-serif;
            font-size: 24px;
            color: #000000a3;
        }

        .mb-3 {
            margin-bottom: 1rem !important;
        }

        h2 {
            font-size: 1.71428571rem;
        }

        .password-toggle {
            right: 0 !important;
            left: auto !important;
            pointer-events: all !important;
            cursor: pointer !important;
        }

        #tenant-validation-icon-loader,
        #tenant-validation-icon-check,
        #tenant-validation-icon-cross {
            left: unset;
            right: 1px;
        }

        p.privacy {
            font-size: 0.9em;
            color: #00000085;
        }

        p.if-redirection-failed {
            color: #999ea2;
        }

        span.pointer {
            cursor: pointer;
        }

        .login-portal.layout .footer {
            padding: 0 8rem;
            border-top: 1px solid #dcdcdc;
        }

        .ui.fluid.container {
            width: 100%;
        }

        @media only screen and (min-width: 1200px) {
            .ui.container {
                width: 1127px;
                margin-left: auto !important;
                margin-right: auto !important;
            }

            .ui.container {
                display: block;
                max-width: 100% !important;
            }
        }

        .login-portal.layout .footer .ui.text.menu {
            margin: 0;
            line-height: 40px;
        }

        .ui.text.menu {
            background: none transparent;
            border-radius: 0;
            box-shadow: none;
            border: none;
            margin: 1em -.5em;
        }

        .ui.menu:last-child {
            margin-bottom: 0;
        }

        .ui.menu:first-child {
            margin-top: 0;
        }

        .ui.menu {
            font-size: 1rem;
        }

        .ui.menu {
            display: flex;
            margin: 1rem 0;
            font-family: -apple-system, BlinkMacSystemFont, Segoe UI, HelveticaNeue-Light, Ubuntu, Droid Sans, sans-serif, font-awesome, 'Helvetica Neue', Arial, Helvetica, sans-serif;
            background: #fbfbfb;
            font-weight: 400;
            border: 1px solid rgba(34, 36, 38, 0.15);
            box-shadow: 0 1px 2px 0 rgb(34 36 38 / 15%);
            border-radius: 4px;
            min-height: 2.85714286em;
        }

        .ui.menu:not(.vertical)>.menu {
            display: flex;
        }

        .ui.menu .menu {
            margin: 0;
        }

        .ui.menu:not(.vertical) .right.item,
        .ui.menu:not(.vertical) .right.menu {
            display: flex;
            margin-left: auto !important;
        }

        .ui.menu:not(.vertical)>.menu {
            display: flex;
        }

        .ui.menu .menu {
            margin: 0;
        }

        .login-portal.layout .footer .ui.text.menu .item {
            color: #909599;
        }

        .ui.text.menu .item {
            border-radius: 0;
            box-shadow: none;
            align-self: center;
            margin: 0 0;
            padding: 0.35714286em 0.5em;
            font-weight: 400;
            color: rgba(0, 0, 0, 0.6);
            transition: opacity 0.1s ease;
        }

        .ui.menu:not(.vertical) .item {
            display: flex;
            align-items: center;
        }

        .ui.menu .item {
            position: relative;
            vertical-align: middle;
            line-height: 1;
            text-decoration: none;
            -webkit-tap-highlight-color: transparent;
            flex: 0 0 auto;
            user-select: none;
            background: 0 0;
            padding: 0.92857143em 1.14285714em;
            text-transform: none;
            color: rgba(0, 0, 0, 0.87);
            font-weight: 400;
            transition: background 0.1s ease, box-shadow 0.1s ease, color 0.1s ease;
        }

        a {
            color: #ff7300;
            text-decoration: none;
        }

        a {
            background-color: transparent;
            -webkit-text-decoration-skip: objects;
        }

        .ui.button {
            cursor: pointer;
            display: inline-block;
            min-height: 1em;
            outline: 0;
            border: none;
            vertical-align: baseline;
            background-color: #ff7300;
            color: #fff;
            font-family: -apple-system, BlinkMacSystemFont, Segoe UI, HelveticaNeue-Light, Ubuntu, Droid Sans,
                sans-serif, font-awesome, "Helvetica Neue", Arial, Helvetica, sans-serif;
            margin: 0 0.25em 0 0;
            padding: 0.78571429em 1.5em 0.78571429em;
            text-transform: none;
            text-shadow: none;
            font-weight: 500;
            line-height: 1em;
            font-style: normal;
            text-align: center;
            text-decoration: none;
            border-radius: 4px;
            box-shadow: 0 0 0 1px transparent inset, 0 0 0 0 rgb(34 36 38 / 15%) inset;
            user-select: none;
            transition: opacity 0.1s ease, background-color 0.1s ease, color 0.1s ease, box-shadow 0.1s ease,
                background 0.1s ease;
            will-change: "";
            -webkit-tap-highlight-color: transparent;
        }
    </style>

    <%-- If an override stylesheet is defined in branding-preferences, applying it... --%>
    <% if (overrideStylesheet != null) { %>
    <link rel="stylesheet" href="<%= StringEscapeUtils.escapeHtml4(overrideStylesheet) %>">
    <% } %>
</head>

<body class="login-portal layout recovery-layout" onload="javascript:document.getElementById('oauth-response').submit()">
    <div class="page-wrapper">
        <main class="center-segment registration-loader">
            <div class="ui container aligned middle aligned text-center">
                <div class="pre-loader-wrapper" data-testid="pre-loader-wrapper">
                    <%
                        if (StringUtils.equals(tenantForTheming, IdentityManagementEndpointConstants.SUPER_TENANT)) {
                            if (enableDefaultPreLoader) {
                    %>
                                <div class="pre-loader-logo">
                                    <svg class="icon" id="is-logo" xmlns="http://www.w3.org/2000/svg" width="255.16" height="23.057" viewBox="0 0 255.16 23.057">
                                        <g id="logo-full" transform="translate(-804.154 2199)">
                                            <g id="wso2-logo" transform="translate(804.154 -2199)">
                                                <circle id="Ellipse_1" data-name="Ellipse 1" cx="7.251" cy="7.251" r="7.251" transform="translate(37.029 1.785)" fill="#f47b20"/>
                                                <path id="Path_326" data-name="Path 326" d="M87.913,2.7,87.9,2.6H85.089l-.029.053q-.5.89-1,1.785l-.29.522q-.752-1.82-1.5-3.64Q81.489-.6,80.7-2.52L80.6-2.742l-.1.219Q79.934-1.266,79.371,0c-.517,1.154-1.052,2.346-1.589,3.514-.748-.007-1.5-.006-2.248-.005-.687,0-1.375,0-2.065,0h-.107l0,.107a5.277,5.277,0,0,0,.069.685l.018.123h.09q1.792,0,3.581,0h1.261l.028-.061q.551-1.216,1.1-2.437Q80.036.744,80.567-.427q.8,1.942,1.6,3.888.7,1.7,1.4,3.4l.082.2.106-.187q.721-1.283,1.434-2.571l.44-.793h2.286l.008-.1A4.451,4.451,0,0,0,87.913,2.7Z" transform="translate(-36.353 5.993)" fill="#fff"/>
                                                <path id="Path_327" data-name="Path 327" d="M29-6.615c.708,0,1.415,0,2.123,0q2.584,6.36,5.171,12.72c1.726-4.249,3.439-8.5,5.183-12.746q2.587,6.376,5.177,12.75Q49.242-.251,51.825-6.616c.715,0,1.432,0,2.147,0Q50.363,2.3,46.748,11.208c-.007.086-.131.228-.16.062Q44.033,4.947,41.476-1.375c-1.739,4.264-3.456,8.537-5.186,12.8Q32.638,2.411,29-6.615Z" transform="translate(-29 6.639)" fill="#f47b20"/>
                                                <path id="Path_328" data-name="Path 328" d="M60.18-5.7a5.7,5.7,0,0,1,3.964-.873,5.112,5.112,0,0,1,3.64,2.68c-.516.34-1.043.662-1.556,1.005-.274-.3-.459-.669-.745-.959A2.671,2.671,0,0,0,64.057-4.7a3.344,3.344,0,0,0-3.115.9A2.29,2.29,0,0,0,61.1-.526,17.566,17.566,0,0,0,63.336.8,18.118,18.118,0,0,1,66.2,2.288a5.372,5.372,0,0,1,1.669,1.541,4.85,4.85,0,0,1,.448,3.249,5.318,5.318,0,0,1-2.4,3.5,5.655,5.655,0,0,1-3.672.808,5.077,5.077,0,0,1-3.127-1.355,6.083,6.083,0,0,1-1.656-3.1c.637-.2,1.273-.386,1.909-.582a4.539,4.539,0,0,0,1.492,2.6,3.485,3.485,0,0,0,2.8.567,3.415,3.415,0,0,0,2.512-2.064A3.52,3.52,0,0,0,66.3,5.236a2.218,2.218,0,0,0-.927-1.2,19.509,19.509,0,0,0-2.824-1.559,14,14,0,0,1-2.172-1.2A4.951,4.951,0,0,1,58.9-.063a4.223,4.223,0,0,1-.445-3.085A4.137,4.137,0,0,1,60.18-5.7Z" transform="translate(-33.716 6.635)" fill="#f47b20"/>
                                                <path id="Path_329" data-name="Path 329" d="M79.612-6.6a9.091,9.091,0,0,1,4.272.721,9.016,9.016,0,0,1,4.4,12.472,9.051,9.051,0,0,1-6.125,4.627A9.113,9.113,0,0,1,77.01,10.8a9.03,9.03,0,0,1-3.971-3.018,8.942,8.942,0,0,1-1.775-4.929,8.955,8.955,0,0,1,1.83-5.927A9.029,9.029,0,0,1,79.612-6.6ZM78.53-4.557A7.208,7.208,0,0,0,73.951-.982,7.517,7.517,0,0,0,73.1,2.965h.02a5.439,5.439,0,0,0,.073.706,7.226,7.226,0,0,0,3.979,5.258,7.174,7.174,0,0,0,5.383.341,7.215,7.215,0,0,0,3.629-2.715,7.158,7.158,0,0,0,1.283-3.793,4.191,4.191,0,0,0-.008-.7,7.2,7.2,0,0,0-5.141-6.54A7.148,7.148,0,0,0,78.53-4.557Z" transform="translate(-36.002 6.636)" fill="#060709"/>
                                                <path id="Path_330" data-name="Path 330" d="M92.939,3.408a5.359,5.359,0,0,1,2.9.013A4.314,4.314,0,0,1,98.609,6.11a4.743,4.743,0,0,1-.481,3.96,18.24,18.24,0,0,1-2.091,2.613q-1.828,1.975-3.66,3.948,3.33-.005,6.66,0c0,.474,0,.948,0,1.422-3.289,0-6.579,0-9.868,0,2.1-2.278,4.223-4.538,6.316-6.824a6.8,6.8,0,0,0,1.876-3.037,2.9,2.9,0,0,0-.822-2.66A3.3,3.3,0,0,0,92.9,4.894,8.266,8.266,0,0,0,92.939,3.408Z" transform="translate(-38.972 5.006)" fill="#060709"/>
                                            </g>
                                            <path id="identity-server-text" d="M2.061-15.063H4.122V0H2.061ZM13.217-1.743a5.64,5.64,0,0,0,1.7-.215A3.744,3.744,0,0,0,16.868-3.5a6.3,6.3,0,0,0,.872-2.338,8.917,8.917,0,0,0,.154-1.579,7.354,7.354,0,0,0-1.113-4.348A4.11,4.11,0,0,0,13.2-13.31H9.577V-1.743ZM7.526-15.063h6.1a5.751,5.751,0,0,1,4.819,2.2,8.128,8.128,0,0,1,1.528,5.1,10.154,10.154,0,0,1-.9,4.337A5.567,5.567,0,0,1,13.607,0H7.526Zm15.268,0H33.776v1.846H24.784v4.573H33.1V-6.9H24.784v5.106H33.93V0H22.794Zm13.812,0h2.41l7.608,12.2v-12.2h1.938V0H46.276L38.555-12.192V0H36.606Zm26.127,0v1.794H57.658V0H55.586V-13.269H50.511v-1.794Zm2.328,0h2.061V0H65.061Zm16.334,0v1.794H76.32V0H74.249V-13.269H69.173v-1.794Zm.7,0h2.379L88.8-7.824l4.327-7.239h2.389L89.824-6.07V0H87.784V-6.07Zm21.974,10.2a4.116,4.116,0,0,0,.6,2.082,4.01,4.01,0,0,0,3.579,1.5,6.334,6.334,0,0,0,2.092-.328,2.324,2.324,0,0,0,1.825-2.276A1.965,1.965,0,0,0,111.4-5.64a7.765,7.765,0,0,0-2.44-.892l-2.041-.461a9.24,9.24,0,0,1-2.83-.995,3.151,3.151,0,0,1-1.436-2.82,4.342,4.342,0,0,1,1.4-3.333,5.636,5.636,0,0,1,3.979-1.3A6.91,6.91,0,0,1,112.06-14.3a4.126,4.126,0,0,1,1.656,3.656H111.8a3.774,3.774,0,0,0-.656-1.856,3.813,3.813,0,0,0-3.168-1.179,3.665,3.665,0,0,0-2.594.759,2.375,2.375,0,0,0-.79,1.764,1.722,1.722,0,0,0,.923,1.62,13.543,13.543,0,0,0,2.738.82l2.112.482a6.472,6.472,0,0,1,2.358.954,3.571,3.571,0,0,1,1.436,3.066,3.827,3.827,0,0,1-1.82,3.579,8.151,8.151,0,0,1-4.23,1.077,6.325,6.325,0,0,1-4.4-1.436,4.844,4.844,0,0,1-1.559-3.866Zm12.869-10.2h10.982v1.846h-8.993v4.573h8.316V-6.9h-8.316v5.106h9.146V0H116.936Zm20.815,6.9a3.954,3.954,0,0,0,2.271-.574,2.338,2.338,0,0,0,.836-2.071A2.222,2.222,0,0,0,139.689-13a3.82,3.82,0,0,0-1.671-.308h-4.983v5.147Zm-6.757-6.9h6.973a6.954,6.954,0,0,1,2.84.5A3.557,3.557,0,0,1,142.929-11a4,4,0,0,1-.559,2.215A4.038,4.038,0,0,1,140.807-7.4a3.081,3.081,0,0,1,1.328.943,3.388,3.388,0,0,1,.5,1.9l.072,2.02a6.21,6.21,0,0,0,.144,1.282,1.26,1.26,0,0,0,.656.923V0H141a1.882,1.882,0,0,1-.164-.5,9.644,9.644,0,0,1-.1-1.189L140.612-4.2a2.111,2.111,0,0,0-1.1-1.979,4.538,4.538,0,0,0-1.835-.277h-4.645V0h-2.041Zm15.74,0,4.327,12.828,4.276-12.828h2.287L152.127,0h-2.164l-5.486-15.063Zm13.012,0h10.982v1.846h-8.993v4.573h8.316V-6.9h-8.316v5.106h9.146V0H159.746Zm20.815,6.9a3.954,3.954,0,0,0,2.271-.574,2.338,2.338,0,0,0,.836-2.071A2.222,2.222,0,0,0,182.5-13a3.82,3.82,0,0,0-1.671-.308h-4.983v5.147Zm-6.757-6.9h6.973a6.954,6.954,0,0,1,2.84.5A3.557,3.557,0,0,1,185.739-11a4,4,0,0,1-.559,2.215A4.038,4.038,0,0,1,183.617-7.4a3.081,3.081,0,0,1,1.328.943,3.388,3.388,0,0,1,.5,1.9l.072,2.02a6.21,6.21,0,0,0,.144,1.282,1.26,1.26,0,0,0,.656.923V0h-2.5a1.882,1.882,0,0,1-.164-.5,9.644,9.644,0,0,1-.1-1.189L183.422-4.2a2.111,2.111,0,0,0-1.1-1.979,4.538,4.538,0,0,0-1.835-.277h-4.645V0H173.8Z" transform="translate(873 -2181.461)"/>
                                        </g>
                                    </svg>
                                </div>
                                <div class="content-loader">
                                    <div class="ui dimmer">
                                        <div class="ui loader"></div>
                                    </div>
                                </div>
                    <%      else { %>
                                <div class="trifacta-pre-loader" data-testid="trifacta-pre-loader">
                                    <svg data-testid="trifacta-pre-loader-svg" xmlns="http://www.w3.org/2000/svg" width="67.56"
                                        height="58.476" viewBox="0 0 67.56 58.476">
                                        <g id="logo-only" transform="translate(-424.967 -306)">
                                            <path id="_3" data-name="3"
                                                d="M734.291,388.98l6.194,10.752-6.868,11.907h13.737l6.226,10.751H714.97Z"
                                                transform="translate(-261.054 -82.98)" fill="#ff7300" />
                                            <path id="_2" data-name="2"
                                                d="M705.95,422.391l6.227-10.751h13.736l-6.867-11.907,6.193-10.752,19.321,33.411Z"
                                                transform="translate(-280.983 -82.98)" fill="#ff7300" />
                                            <path id="_1" data-name="1"
                                                d="M736.65,430.2l-6.868-11.907-6.9,11.907H710.46l19.322-33.411L749.071,430.2Z"
                                                transform="translate(-271.019 -65.725)" fill="#000" />
                                        </g>
                                    </svg>
                                </div>
                    <%      } %>
                    <% } else { %>
                        <img class="pre-loader-logo" alt="<%= StringEscapeUtils.escapeHtml4(logoAlt) %>" src="<%= StringEscapeUtils.escapeHtml4(logoURL) %>">
                        <div class="content-loader">
                            <div class="ui dimmer">
                                <div class="ui loader"></div>
                            </div>
                        </div>
                    <% } %> 
                </div>
                <p class="message-description">
                    <a class="primary-color-btn button"
                        href="javascript:document.getElementById('oauth-response').submit()">
                        <%=AuthenticationEndpointUtil.i18n(resourceBundle, "click.here")%>
                    </a>
                    <%=AuthenticationEndpointUtil.i18n(resourceBundle, "if.you.have.been.waiting.for.too.long")%>
                </p>
                <form id="oauth-response" method="post" action="${redirectURI}">
                <% String params = (String) request.getAttribute("params"); %>
                <%= params %>
                </form>
            </div>
        </main>
    </div>
</body>

</html>
