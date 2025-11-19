import axios, { AxiosInstance } from 'axios';
import * as vscode from 'vscode';

interface CodeCatalystConfig {
    backendUrl: string;
    enableInlineHints: boolean;
    autoAuditOnSave: boolean;
    enableTutorials: boolean;
    language: string;
}

class CodeCatalystExtension {
    private context: vscode.ExtensionContext;
    private apiClient: AxiosInstance;
    private config: CodeCatalystConfig;
    private statusBar: vscode.StatusBarItem;
    private diagnosticCollection: vscode.DiagnosticCollection;
    private tutorialShown: boolean = false;

    constructor(context: vscode.ExtensionContext) {
        this.context = context;
        this.config = this.loadConfig();
        this.apiClient = axios.create({
            baseURL: this.config.backendUrl,
            timeout: 30000,
        });
        this.statusBar = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Right, 100);
        this.diagnosticCollection = vscode.languages.createDiagnosticCollection('codeCatalyst');
    }

    private loadConfig(): CodeCatalystConfig {
        const config = vscode.workspace.getConfiguration('codeCatalyst');
        return {
            backendUrl: config.get('backendUrl') || 'http://localhost:8001',
            enableInlineHints: config.get('enableInlineHints') ?? true,
            autoAuditOnSave: config.get('autoAuditOnSave') ?? false,
            enableTutorials: config.get('enableTutorials') ?? true,
            language: config.get('language') || 'dart',
        };
    }

    async activate(): Promise<void> {
        console.log('🚀 Code Catalyst extension activated');

        // Register commands
        this.registerCommands();

        // Setup event listeners
        this.setupEventListeners();

        // Show tutorial if enabled
        if (this.config.enableTutorials && !this.tutorialShown) {
            this.showTutorial();
            this.tutorialShown = true;
        }

        // Update status bar
        this.updateStatusBar('ready');

        // Check backend health
        await this.checkBackendHealth();
    }

    private registerCommands(): void {
        // Quick fix command
        this.context.subscriptions.push(
            vscode.commands.registerCommand('codeCatalyst.quickFix', async () => {
                await this.getQuickFix();
            })
        );

        // Analyze command
        this.context.subscriptions.push(
            vscode.commands.registerCommand('codeCatalyst.analyze', async () => {
                await this.analyzeCode();
            })
        );

        // Security audit command
        this.context.subscriptions.push(
            vscode.commands.registerCommand('codeCatalyst.auditSecurity', async () => {
                await this.auditSecurity();
            })
        );

        // Smart contract analysis
        this.context.subscriptions.push(
            vscode.commands.registerCommand('codeCatalyst.analyzeContract', async () => {
                await this.analyzeSmartContract();
            })
        );

        // Tutorial command
        this.context.subscriptions.push(
            vscode.commands.registerCommand('codeCatalyst.openTutorial', async () => {
                this.showTutorial();
            })
        );

        // Settings command
        this.context.subscriptions.push(
            vscode.commands.registerCommand('codeCatalyst.openSettings', async () => {
                vscode.commands.executeCommand('workbench.action.openSettings', 'codeCatalyst');
            })
        );
    }

    private setupEventListeners(): void {
        // Listen for file save
        this.context.subscriptions.push(
            vscode.workspace.onDidSaveTextDocument(async (doc) => {
                if (this.config.autoAuditOnSave) {
                    await this.auditSecurity(doc);
                }
            })
        );

        // Listen for configuration changes
        this.context.subscriptions.push(
            vscode.workspace.onDidChangeConfiguration((e) => {
                if (e.affectsConfiguration('codeCatalyst')) {
                    this.config = this.loadConfig();
                    this.apiClient.defaults.baseURL = this.config.backendUrl;
                }
            })
        );

        // Listen for editor changes
        this.context.subscriptions.push(
            vscode.window.onDidChangeActiveTextEditor(async (editor) => {
                if (editor && this.config.enableInlineHints) {
                    await this.updateInlineHints(editor.document);
                }
            })
        );
    }

    private async getQuickFix(): Promise<void> {
        const editor = vscode.window.activeTextEditor;
        if (!editor) {
            vscode.window.showWarningMessage('No file is currently open');
            return;
        }

        this.updateStatusBar('analyzing...');

        try {
            const code = editor.document.getText();
            const language = editor.document.languageId;

            const response = await this.apiClient.post('/api/suggest', {
                code,
                language,
                prompt: 'Improve this code',
                context: 'wealthbridge',
            });

            if (response.status === 200) {
                const suggestion = response.data;
                await this.showSuggestionQuickPick(suggestion, editor);
                this.updateStatusBar('ready');
            }
        } catch (error: any) {
            vscode.window.showErrorMessage(`Code Catalyst Error: ${error.message}`);
            this.updateStatusBar('error');
        }
    }

    private async analyzeCode(): Promise<void> {
        const editor = vscode.window.activeTextEditor;
        if (!editor) {
            vscode.window.showWarningMessage('No file is currently open');
            return;
        }

        this.updateStatusBar('analyzing...');

        try {
            const code = editor.document.getText();
            const language = editor.document.languageId;

            const response = await this.apiClient.post('/api/analyze-contract', {
                contract_code: code,
                language,
                check_vulnerabilities: true,
            });

            if (response.status === 200) {
                await this.showAnalysisResults(response.data);
                this.updateStatusBar('ready');
            }
        } catch (error: any) {
            vscode.window.showErrorMessage(`Analysis failed: ${error.message}`);
            this.updateStatusBar('error');
        }
    }

    private async auditSecurity(doc?: vscode.TextDocument): Promise<void> {
        const editor = vscode.window.activeTextEditor;
        const document = doc || editor?.document;

        if (!document) {
            vscode.window.showWarningMessage('No file is currently open');
            return;
        }

        this.updateStatusBar('auditing...');

        try {
            const code = document.getText();
            const language = document.languageId;

            const response = await this.apiClient.post('/api/audit', {
                code,
                language,
                scan_secrets: true,
                scan_vulnerabilities: true,
            });

            if (response.status === 200) {
                const diagnostics = this.generateDiagnostics(response.data, document);
                this.diagnosticCollection.set(document.uri, diagnostics);

                vscode.window.showInformationMessage(
                    `🔒 Security audit complete: ${diagnostics.length} issues found`
                );
                this.updateStatusBar('ready');
            }
        } catch (error: any) {
            vscode.window.showErrorMessage(`Audit failed: ${error.message}`);
            this.updateStatusBar('error');
        }
    }

    private async analyzeSmartContract(): Promise<void> {
        const editor = vscode.window.activeTextEditor;
        if (!editor) {
            vscode.window.showWarningMessage('No file is currently open');
            return;
        }

        if (editor.document.languageId !== 'solidity') {
            vscode.window.showWarningMessage('This command works with Solidity files');
            return;
        }

        this.updateStatusBar('analyzing contract...');

        try {
            const contract = editor.document.getText();

            const response = await this.apiClient.post('/api/analyze-contract', {
                contract_code: contract,
                language: 'solidity',
                check_vulnerabilities: true,
            });

            if (response.status === 200) {
                await this.showContractAnalysisResults(response.data);
                this.updateStatusBar('ready');
            }
        } catch (error: any) {
            vscode.window.showErrorMessage(`Contract analysis failed: ${error.message}`);
            this.updateStatusBar('error');
        }
    }

    private async updateInlineHints(document: vscode.TextDocument): Promise<void> {
        try {
            const code = document.getText();
            const response = await this.apiClient.post('/api/suggest', {
                code,
                language: document.languageId,
                prompt: 'Quick tips',
                context: 'wealthbridge',
            });

            if (response.data.hints) {
                // Display hints as CodeLens or hover information
                console.log('💡 Hints:', response.data.hints);
            }
        } catch (error) {
            // Silent fail for inline hints
        }
    }

    private generateDiagnostics(
        auditResult: any,
        document: vscode.TextDocument
    ): vscode.Diagnostic[] {
        const diagnostics: vscode.Diagnostic[] = [];
        const findings = auditResult.findings || {};

        // Parse findings and create diagnostics
        if (findings.vulnerabilities) {
            findings.vulnerabilities.forEach((vuln: any, index: number) => {
                const diagnostic = new vscode.Diagnostic(
                    new vscode.Range(index, 0, index, 100),
                    `🔴 Vulnerability: ${vuln}`,
                    vscode.DiagnosticSeverity.Error
                );
                diagnostics.push(diagnostic);
            });
        }

        if (findings.secrets_found && findings.secrets_found > 0) {
            const diagnostic = new vscode.Diagnostic(
                new vscode.Range(0, 0, 0, 100),
                `🔒 ${findings.secrets_found} potential secrets found`,
                vscode.DiagnosticSeverity.Warning
            );
            diagnostics.push(diagnostic);
        }

        return diagnostics;
    }

    private async showSuggestionQuickPick(suggestion: any, editor: vscode.TextEditor): Promise<void> {
        const options: vscode.QuickPickItem[] = [
            {
                label: '✅ Apply Suggestion',
                description: 'Insert the suggested code',
            },
            {
                label: '📋 Copy to Clipboard',
                description: 'Copy suggestion to clipboard',
            },
            {
                label: '❌ Dismiss',
                description: 'Close this menu',
            },
        ];

        const choice = await vscode.window.showQuickPick(options);

        if (choice?.label.includes('Apply')) {
            const edit = new vscode.WorkspaceEdit();
            edit.replace(
                editor.document.uri,
                new vscode.Range(0, 0, editor.document.lineCount, 0),
                suggestion.code || ''
            );
            await vscode.workspace.applyEdit(edit);
        } else if (choice?.label.includes('Copy')) {
            await vscode.env.clipboard.writeText(suggestion.code || '');
            vscode.window.showInformationMessage('✅ Copied to clipboard');
        }
    }

    private async showAnalysisResults(analysis: any): Promise<void> {
        const panel = vscode.window.createWebviewPanel(
            'codeAnalysis',
            'Code Analysis Results',
            vscode.ViewColumn.Beside,
            { enableScripts: true }
        );

        panel.webview.html = `
            <!DOCTYPE html>
            <html>
            <head>
                <style>
                    body { font-family: var(--vscode-font-family); margin: 20px; }
                    h2 { color: var(--vscode-foreground); }
                    .issue { margin: 10px 0; padding: 10px; background: var(--vscode-editor-background); border-left: 3px solid #f44336; }
                    .optimization { margin: 10px 0; padding: 10px; background: var(--vscode-editor-background); border-left: 3px solid #2196f3; }
                </style>
            </head>
            <body>
                <h2>📊 Analysis Results</h2>
                ${analysis.vulnerabilities ? `<div class="issue"><strong>Vulnerabilities:</strong><br>${analysis.vulnerabilities.join('<br>')}</div>` : ''}
                ${analysis.optimizations ? `<div class="optimization"><strong>Optimizations:</strong><br>${analysis.optimizations.join('<br>')}</div>` : ''}
            </body>
            </html>
        `;
    }

    private async showContractAnalysisResults(analysis: any): Promise<void> {
        const panel = vscode.window.createWebviewPanel(
            'contractAnalysis',
            'Smart Contract Analysis',
            vscode.ViewColumn.Beside,
            { enableScripts: true }
        );

        panel.webview.html = `
            <!DOCTYPE html>
            <html>
            <head>
                <style>
                    body { font-family: var(--vscode-font-family); margin: 20px; }
                    h2 { color: var(--vscode-foreground); }
                    .critical { color: #f44336; font-weight: bold; }
                    .warning { color: #ff9800; }
                    .safe { color: #4caf50; }
                </style>
            </head>
            <body>
                <h2>🔍 Smart Contract Analysis</h2>
                <p>Contract Name: ${analysis.contract_name || 'Unknown'}</p>
                <p class="${analysis.safe ? 'safe' : 'critical'}">
                    Status: ${analysis.safe ? '✅ Safe' : '❌ Issues Found'}
                </p>
                ${analysis.vulnerabilities ? `<div class="critical"><strong>Vulnerabilities:</strong><br>${analysis.vulnerabilities.join('<br>')}</div>` : ''}
                ${analysis.optimizations ? `<div class="warning"><strong>Optimizations:</strong><br>${analysis.optimizations.join('<br>')}</div>` : ''}
            </body>
            </html>
        `;
    }

    private showTutorial(): void {
        const panel = vscode.window.createWebviewPanel(
            'codeCatalystTutorial',
            '🧠 Code Catalyst Tutorial',
            vscode.ViewColumn.One,
            { enableScripts: true }
        );

        panel.webview.html = `
            <!DOCTYPE html>
            <html>
            <head>
                <style>
                    body { font-family: var(--vscode-font-family); margin: 30px; line-height: 1.6; }
                    h1 { color: #5B2A86; }
                    h2 { color: #0D1B2A; margin-top: 20px; }
                    .step { background: #f5f5f5; padding: 15px; margin: 10px 0; border-radius: 5px; }
                    .shortcut { background: #fff3cd; padding: 10px; border-radius: 3px; font-family: monospace; }
                    button { background: #5B2A86; color: white; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer; margin: 10px 0; }
                    button:hover { background: #4A1F70; }
                </style>
            </head>
            <body>
                <h1>🧠 Welcome to Code Catalyst</h1>
                <p>Your AI-powered development assistant for the Influwealth ecosystem.</p>

                <h2>🎯 Quick Start</h2>
                <div class="step">
                    <strong>Step 1: Get AI Suggestions</strong>
                    <div class="shortcut">Ctrl+Alt+C (Cmd+Alt+C on Mac)</div>
                    <p>Select code and press the shortcut to get AI suggestions for improvements.</p>
                </div>

                <div class="step">
                    <strong>Step 2: Security Audit</strong>
                    <div class="shortcut">Ctrl+Shift+S (Cmd+Shift+S on Mac)</div>
                    <p>Scan your code for security vulnerabilities and secrets.</p>
                </div>

                <div class="step">
                    <strong>Step 3: Analyze Smart Contracts</strong>
                    <p>Right-click on Solidity files and select "Code Catalyst: Analyze Smart Contract".</p>
                </div>

                <h2>✨ Features</h2>
                <ul>
                    <li>✅ AI-powered code suggestions</li>
                    <li>✅ Security scanning & vulnerability detection</li>
                    <li>✅ Smart contract analysis</li>
                    <li>✅ Code generation from natural language</li>
                    <li>✅ Multi-language support (Dart, Solidity, JS, Python, Rust)</li>
                </ul>

                <h2>⚙️ Configuration</h2>
                <p>Open Settings (Cmd+Palette → "Code Catalyst: Open Settings") to customize behavior.</p>

                <button onclick="vscode.postMessage({command: 'closeTutorial'})">Got it! 👍</button>
            </body>
            </html>
        `;
    }

    private updateStatusBar(status: string): void {
        const icons: { [key: string]: string } = {
            ready: '✅',
            analyzing: '🔍',
            auditing: '🔒',
            error: '❌',
        };
        this.statusBar.text = `${icons[status] || '•'} Code Catalyst`;
        this.statusBar.show();
    }

    private async checkBackendHealth(): Promise<void> {
        try {
            const response = await this.apiClient.get('/health');
            if (response.status === 200) {
                console.log('✅ Backend is healthy');
            }
        } catch (error) {
            vscode.window.showWarningMessage(
                '⚠️ Code Catalyst backend is not responding. Make sure it\'s running on ' +
                this.config.backendUrl
            );
        }
    }
}

export function activate(context: vscode.ExtensionContext) {
    const extension = new CodeCatalystExtension(context);
    extension.activate();
}

export function deactivate() {
    console.log('Code Catalyst extension deactivated');
}
