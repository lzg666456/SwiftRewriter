// Generated from /Users/luizfernandosilva/Documents/Projetos/objcgrammar/two-step-processing/ObjectiveCPreprocessorLexer.g4 by ANTLR 4.8
import Antlr4

open class ObjectiveCPreprocessorLexer: Lexer {
    public class State {
        public let _ATN: ATN = ATNDeserializer().deserializeFromJson(_serializedATN)
        
        internal var _decisionToDFA: [DFA<LexerATNConfig>]
        internal let _sharedContextCache: PredictionContextCache = PredictionContextCache()
        let atnConfigPool: LexerATNConfigPool = LexerATNConfigPool()
        
        public init() {
            var decisionToDFA = [DFA<LexerATNConfig>]()
            let length = _ATN.getNumberOfDecisions()
            for i in 0..<length {
                decisionToDFA.append(DFA(_ATN.getDecisionState(i)!, i))
            }
            _decisionToDFA = decisionToDFA
        }
    }
    
    public var _ATN: ATN {
        return state._ATN
    }
    internal var _decisionToDFA: [DFA<LexerATNConfig>] {
        return state._decisionToDFA
    }
    internal var _sharedContextCache: PredictionContextCache {
        return state._sharedContextCache
    }
    
    public var state: State

	public
	static let SHARP=1, CODE=2, IMPORT=3, INCLUDE=4, PRAGMA=5, DEFINE=6, DEFINED=7, 
            IF=8, ELIF=9, ELSE=10, UNDEF=11, IFDEF=12, IFNDEF=13, ENDIF=14, 
            TRUE=15, FALSE=16, ERROR=17, WARNING=18, BANG=19, LPAREN=20, 
            RPAREN=21, EQUAL=22, NOTEQUAL=23, AND=24, OR=25, LT=26, GT=27, 
            LE=28, GE=29, DIRECTIVE_WHITESPACES=30, DIRECTIVE_STRING=31, 
            CONDITIONAL_SYMBOL=32, DECIMAL_LITERAL=33, FLOAT=34, NEW_LINE=35, 
            DIRECITVE_COMMENT=36, DIRECITVE_LINE_COMMENT=37, DIRECITVE_NEW_LINE=38, 
            DIRECITVE_TEXT_NEW_LINE=39, TEXT=40, SLASH=41

	public
	static let COMMENTS_CHANNEL=2
	public
	static let DIRECTIVE_MODE=1, DIRECTIVE_DEFINE=2, DIRECTIVE_TEXT=3
	public
	static let channelNames: [String] = [
		"DEFAULT_TOKEN_CHANNEL", "HIDDEN", "COMMENTS_CHANNEL"
	]

	public
	static let modeNames: [String] = [
		"DEFAULT_MODE", "DIRECTIVE_MODE", "DIRECTIVE_DEFINE", "DIRECTIVE_TEXT"
	]

	public
	static let ruleNames: [String] = [
		"SHARP", "COMMENT", "LINE_COMMENT", "SLASH", "CHARACTER_LITERAL", "QUOTE_STRING", 
		"STRING", "CODE", "IMPORT", "INCLUDE", "PRAGMA", "DEFINE", "DEFINED", 
		"IF", "ELIF", "ELSE", "UNDEF", "IFDEF", "IFNDEF", "ENDIF", "TRUE", "FALSE", 
		"ERROR", "WARNING", "BANG", "LPAREN", "RPAREN", "EQUAL", "NOTEQUAL", "AND", 
		"OR", "LT", "GT", "LE", "GE", "DIRECTIVE_WHITESPACES", "DIRECTIVE_STRING", 
		"CONDITIONAL_SYMBOL", "DECIMAL_LITERAL", "FLOAT", "NEW_LINE", "DIRECITVE_COMMENT", 
		"DIRECITVE_LINE_COMMENT", "DIRECITVE_NEW_LINE", "DIRECTIVE_DEFINE_CONDITIONAL_SYMBOL", 
		"DIRECITVE_TEXT_NEW_LINE", "BACK_SLASH_ESCAPE", "TEXT_NEW_LINE", "DIRECTIVE_COMMENT", 
		"DIRECTIVE_LINE_COMMENT", "DIRECTIVE_SLASH", "TEXT", "EscapeSequence", 
		"OctalEscape", "UnicodeEscape", "HexDigit", "StringFragment", "LETTER", 
		"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", 
		"O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
	]

	private static let _LITERAL_NAMES: [String?] = [
		nil, "'#'", nil, nil, nil, "'pragma'", nil, "'defined'", "'if'", "'elif'", 
		"'else'", "'undef'", "'ifdef'", "'ifndef'", "'endif'", nil, nil, "'error'", 
		"'warning'", "'!'", "'('", "')'", "'=='", "'!='", "'&&'", "'||'", "'<'", 
		"'>'", "'<='", "'>='"
	]
	private static let _SYMBOLIC_NAMES: [String?] = [
		nil, "SHARP", "CODE", "IMPORT", "INCLUDE", "PRAGMA", "DEFINE", "DEFINED", 
		"IF", "ELIF", "ELSE", "UNDEF", "IFDEF", "IFNDEF", "ENDIF", "TRUE", "FALSE", 
		"ERROR", "WARNING", "BANG", "LPAREN", "RPAREN", "EQUAL", "NOTEQUAL", "AND", 
		"OR", "LT", "GT", "LE", "GE", "DIRECTIVE_WHITESPACES", "DIRECTIVE_STRING", 
		"CONDITIONAL_SYMBOL", "DECIMAL_LITERAL", "FLOAT", "NEW_LINE", "DIRECITVE_COMMENT", 
		"DIRECITVE_LINE_COMMENT", "DIRECITVE_NEW_LINE", "DIRECITVE_TEXT_NEW_LINE", 
		"TEXT", "SLASH"
	]
	public
	static let VOCABULARY = Vocabulary(_LITERAL_NAMES, _SYMBOLIC_NAMES)


	override open
	func getVocabulary() -> Vocabulary {
		return ObjectiveCPreprocessorLexer.VOCABULARY
	}

	public required convenience
    init(_ input: CharStream) {
        self.init(input, State())
    }
    
    public
    init(_ input: CharStream, _ state: State) {
        self.state = state
        
        RuntimeMetaData.checkVersion("4.7", RuntimeMetaData.VERSION)
        super.init(input)
        _interp = LexerATNSimulator(self,
                                    _ATN,
                                    _decisionToDFA,
                                    _sharedContextCache,
                                    lexerAtnConfigPool: state.atnConfigPool)
    }

	override open
	func getGrammarFileName() -> String { return "ObjectiveCPreprocessorLexer.g4" }

	override open
	func getRuleNames() -> [String] { return ObjectiveCPreprocessorLexer.ruleNames }

	override open
	func getSerializedATN() -> String { return ObjectiveCPreprocessorLexer._serializedATN }

	override open
	func getChannelNames() -> [String] { return ObjectiveCPreprocessorLexer.channelNames }

	override open
	func getModeNames() -> [String] { return ObjectiveCPreprocessorLexer.modeNames }

	override open
    func getATN() -> ATN { return _ATN }


	public
	static let _serializedATN: String = ObjectiveCPreprocessorLexerATN().jsonString
}
