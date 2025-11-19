"""
Dart Capsule Agent Specialization
Expert Dart code generation for WealthBridge capsules
Understands: StatelessWidget, StatefulWidget, patterns, best practices
"""

import logging
from typing import Optional, Dict, List
from enum import Enum

logger = logging.getLogger(__name__)


class CapsuleType(Enum):
    """WealthBridge capsule types"""
    STATELESS = "stateless_widget"
    STATEFUL = "stateful_widget"
    DATA_PROVIDER = "data_provider"
    SERVICE = "service"
    MODEL = "model"
    UTILITY = "utility"


class DartAgentSpecialization:
    """
    Expert Dart/Flutter agent for WealthBridge capsules
    Provides domain-specific code generation and review
    """

    def __init__(self):
        self.wealthbridge_patterns = {
            "stateful_widget": """
class {ClassName}Capsule extends StatefulWidget {{
  const {ClassName}Capsule({{Key? key}}) : super(key: key);

  @override
  State<{ClassName}Capsule> createState() => _{ClassName}CapsuleState();
}}

class _{ClassName}CapsuleState extends State<{ClassName}Capsule> {{
  @override
  void initState() {{
    super.initState();
    // Initialize capsule state
  }}

  @override
  Widget build(BuildContext context) {{
    return Scaffold(
      appBar: AppBar(
        title: const Text('{CapsuleName}'),
      ),
      body: Center(
        child: Text('Building {CapsuleName} capsule'),
      ),
    );
  }}
}}
            """,
            "stateless_widget": """
class {ClassName}Capsule extends StatelessWidget {{
  const {ClassName}Capsule({{Key? key}}) : super(key: key);

  @override
  Widget build(BuildContext context) {{
    return Scaffold(
      appBar: AppBar(
        title: const Text('{CapsuleName}'),
      ),
      body: const Center(
        child: Text('{CapsuleName} Capsule'),
      ),
    );
  }}
}}
            """,
            "service": """
class {ServiceName}Service {{
  static const String _tag = '{ServiceName}';
  
  // Singleton instance
  static final {ServiceName}Service _instance = {ServiceName}Service._();
  
  factory {ServiceName}Service() {{
    return _instance;
  }}
  
  {ServiceName}Service._();

  // Service methods here
  Future<void> initialize() async {{
    logger.d('$_tag initialized');
  }}
}}
            """,
        }

        # WealthBridge best practices
        self.best_practices = [
            "Use const constructors for performance",
            "Implement proper state management (Provider, BLoC, GetX)",
            "Handle loading, error, and empty states",
            "Use capsule registry for discovery",
            "Implement proper error logging",
            "Follow Dart naming conventions (camelCase for vars, PascalCase for classes)",
            "Use type annotations for all public APIs",
            "Implement proper dispose patterns for streams",
            "Use VaultGemma for sensitive data",
        ]

    def generate_capsule(
        self,
        capsule_name: str,
        capsule_type: CapsuleType = CapsuleType.STATEFUL,
        description: str = "",
        functionality: List[str] = None,
    ) -> Dict:
        """
        Generate a new WealthBridge capsule
        
        Args:
            capsule_name: Name of the capsule (e.g., "AP2Affiliate")
            capsule_type: Type of capsule (stateful, stateless, service)
            description: What the capsule does
            functionality: List of features to implement
        
        Returns:
            Generated code and metadata
        """

        class_name = self._to_pascal_case(capsule_name)
        template = self.wealthbridge_patterns.get(
            capsule_type.value, self.wealthbridge_patterns["stateful_widget"]
        )

        generated_code = template.format(
            ClassName=class_name,
            CapsuleName=capsule_name,
            ServiceName=class_name,
        )

        result = {
            "capsule_name": capsule_name,
            "class_name": class_name,
            "type": capsule_type.value,
            "description": description,
            "functionality": functionality or [],
            "generated_code": generated_code,
            "file_path": f"lib/widgets/{self._to_snake_case(capsule_name)}_capsule.dart",
            "best_practices": self.best_practices,
            "next_steps": [
                "1. Review generated code",
                "2. Implement custom functionality in marked sections",
                "3. Add state management (Provider/BLoC)",
                "4. Register in capsule_registry.dart",
                "5. Test with flutter test",
                "6. Add to SIMA2Agent orchestration if needed",
            ],
        }

        logger.info(
            f"✅ Generated Dart capsule: {capsule_name} ({capsule_type.value})"
        )

        return result

    def review_capsule_code(
        self,
        code: str,
        capsule_name: str = "",
    ) -> Dict:
        """
        Review Dart capsule code against best practices
        
        Returns:
            Issues found, severity level, and suggestions
        """

        issues = []
        warnings = 0
        errors = 0

        # Check 1: Const constructors
        if "StatelessWidget" in code and "const " not in code:
            issues.append({
                "severity": "warning",
                "type": "missing_const",
                "message": "StatelessWidget constructor should be const",
                "suggestion": "Add 'const' keyword to constructor",
            })
            warnings += 1

        # Check 2: Proper widget structure
        if "build(BuildContext context)" not in code:
            issues.append({
                "severity": "error",
                "type": "missing_build",
                "message": "Missing required build() method",
                "suggestion": "Implement build() method",
            })
            errors += 1

        # Check 3: Key parameter
        if "Key?" not in code and "StatelessWidget" in code:
            issues.append({
                "severity": "warning",
                "type": "missing_key",
                "message": "Consider adding Key parameter for better widget identification",
                "suggestion": "Add Key? key parameter to constructor",
            })
            warnings += 1

        # Check 4: Proper naming
        if "State<" in code and not code.count("_"):
            issues.append({
                "severity": "warning",
                "type": "naming_convention",
                "message": "Private state classes should start with underscore",
                "suggestion": "Rename to _PrivateStateName",
            })
            warnings += 1

        result = {
            "capsule_name": capsule_name,
            "total_issues": len(issues),
            "errors": errors,
            "warnings": warnings,
            "issues": issues,
            "code_quality_score": max(0, 100 - (errors * 20 + warnings * 5)),
            "pass_review": errors == 0,
        }

        logger.info(
            f"📋 Code review: {capsule_name} - "
            f"Errors: {errors}, Warnings: {warnings}"
        )

        return result

    def suggest_improvements(self, code: str) -> List[str]:
        """Suggest improvements for existing Dart code"""
        suggestions = []

        # Performance suggestions
        if "setState" in code:
            suggestions.append(
                "Consider using state management library (Provider/BLoC/GetX) "
                "to reduce unnecessary rebuilds"
            )

        if "Future.delayed" in code:
            suggestions.append("Use proper async/await patterns instead of Future.delayed")

        if "print(" in code:
            suggestions.append("Use logger instead of print() for better observability")

        # Security suggestions
        if "password" in code.lower() and "VaultGemma" not in code:
            suggestions.append(
                "Sensitive data detected. Consider using VaultGemma encryption"
            )

        # Best practices
        if "try {" in code and "catch" not in code:
            suggestions.append("Add proper exception handling to async operations")

        return suggestions

    def generate_test_template(self, capsule_name: str) -> str:
        """Generate test template for capsule"""
        class_name = self._to_pascal_case(capsule_name)
        
        template = f"""
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wealthbridge/widgets/{self._to_snake_case(capsule_name)}_capsule.dart';

void main() {{
  group('{class_name} Capsule Tests', () {{
    testWidgets('{class_name} renders correctly',
        (WidgetTester tester) async {{
      await tester.pumpWidget(
        const MaterialApp(
          home: {class_name}Capsule(),
        ),
      );

      expect(find.byType({class_name}Capsule), findsOneWidget);
    }});

    testWidgets('{class_name} handles user interaction',
        (WidgetTester tester) async {{
      await tester.pumpWidget(
        const MaterialApp(
          home: {class_name}Capsule(),
        ),
      );

      // Add your interaction tests here
    }});
  }});
}}
        """
        return template

    # Helper methods
    @staticmethod
    def _to_pascal_case(snake_str: str) -> str:
        """Convert snake_case to PascalCase"""
        components = snake_str.split("_")
        return "".join(x.title() for x in components)

    @staticmethod
    def _to_snake_case(pascal_str: str) -> str:
        """Convert PascalCase to snake_case"""
        result = []
        for i, char in enumerate(pascal_str):
            if char.isupper() and i > 0:
                result.append("_")
            result.append(char.lower())
        return "".join(result)


# Singleton instance
dart_agent = DartAgentSpecialization()


async def generate_dart_capsule(
    capsule_name: str,
    capsule_type: str = "stateful",
    description: str = "",
    functionality: List[str] = None,
) -> Dict:
    """
    API endpoint helper to generate Dart capsule
    """
    try:
        capsule_type_enum = CapsuleType[capsule_type.upper()]
    except KeyError:
        capsule_type_enum = CapsuleType.STATEFUL

    return dart_agent.generate_capsule(
        capsule_name=capsule_name,
        capsule_type=capsule_type_enum,
        description=description,
        functionality=functionality or [],
    )


async def review_dart_code(code: str, capsule_name: str = "") -> Dict:
    """API endpoint helper to review Dart code"""
    return dart_agent.review_capsule_code(code, capsule_name)
