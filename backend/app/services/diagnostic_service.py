from typing import List, Dict, Any

class DiagnosticService:
    """
    Service to analyze chromosome counts and suggest potential diagnoses based on ISCN standards.
    """
    
    COMMON_SYNDROMES = [
        {"iscn": "46,XX", "description": "Nữ giới bình thường", "condition": lambda counts, sex: counts == 46 and sex == "XX"},
        {"iscn": "46,XY", "description": "Nam giới bình thường", "condition": lambda counts, sex: counts == 46 and sex == "XY"},
        {"iscn": "47,XX,+21", "description": "Hội chứng Down (Nữ)", "condition": lambda counts, sex: counts == 47 and sex == "XX" and "+21" in counts_str},
        {"iscn": "47,XY,+21", "description": "Hội chứng Down (Nam)", "condition": lambda counts, sex: counts == 47 and sex == "XY" and "+21" in counts_str},
        {"iscn": "47,XX,+18", "description": "Hội chứng Edwards", "condition": lambda counts, sex: counts == 47 and "+18" in counts_str},
        {"iscn": "47,XX,+13", "description": "Hội chứng Patau", "condition": lambda counts, sex: counts == 47 and "+13" in counts_str},
        {"iscn": "45,X", "description": "Hội chứng Turner", "condition": lambda counts, sex: counts == 45 and sex == "X"},
        {"iscn": "47,XXY", "description": "Hội chứng Klinefelter", "condition": lambda counts, sex: counts == 47 and sex == "XXY"},
        {"iscn": "47,XXX", "description": "Hội chứng Triple X", "condition": lambda counts, sex: counts == 47 and sex == "XXX"},
        {"iscn": "47,XYY", "description": "Hội chứng XYY", "condition": lambda counts, sex: counts == 47 and sex == "XYY"},
    ]

    def analyze(self, chromosomes: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """
        Analyzes the list of chromosomes and returns suggested diagnoses.
        """
        # 1. Count by label
        counts_map = {}
        for chrom in chromosomes:
            label = chrom.get('label', 'unassigned')
            counts_map[label] = counts_map.get(label, 0) + 1
            
        total_count = len(chromosomes)
        
        # 2. Determine sex chromosomes
        x_count = counts_map.get('X', 0)
        y_count = counts_map.get('Y', 0)
        
        sex_str = ""
        if x_count > 0:
            sex_str += "X" * x_count
        if y_count > 0:
            sex_str += "Y" * y_count
            
        # 3. Identify trisomies/monosomies
        abnormalities = []
        for label, count in counts_map.items():
            if label in ['X', 'Y', 'unassigned']:
                continue
            
            if count > 2:
                abnormalities.append(f"+{label}")
            elif count < 2:
                abnormalities.append(f"-{label}")
        
        # Global variables for the lambda context
        global_counts_str = ",".join(abnormalities)
        
        suggestions = []
        
        # Match against common syndromes
        found_exact = False
        
        # Helper for condition matching
        def matches(syndrome):
            try:
                # Custom logic for simplicity instead of lambda for more complex ones
                s_iscn = syndrome['iscn']
                if total_count == 46 and sex_str in ["XX", "XY"] and not abnormalities:
                    return s_iscn == f"46,{sex_str}"
                
                if total_count == 47:
                    if "+21" in abnormalities and s_iscn.endswith("+21"):
                        return s_iscn.startswith(f"47,{sex_str}") if sex_str else True
                    if "+18" in abnormalities and s_iscn.endswith("+18"):
                        return True
                    if "+13" in abnormalities and s_iscn.endswith("+13"):
                        return True
                    if sex_str in ["XXY", "XXX", "XYY"] and s_iscn == f"47,{sex_str}":
                        return True
                
                if total_count == 45 and sex_str == "X" and s_iscn == "45,X":
                    return True
                    
                return False
            except:
                return False

        for syndrome in self.COMMON_SYNDROMES:
            if matches(syndrome):
                suggestions.append({
                    "iscn": syndrome['iscn'],
                    "description": syndrome['description'],
                    "confidence": 0.99
                })
                found_exact = True
        
        # If no exact match, construct a generic ISCN
        if not found_exact:
            generic_iscn = f"{total_count},{sex_str or '?'}"
            if abnormalities:
                generic_iscn += "," + ",".join(abnormalities)
            
            suggestions.append({
                "iscn": generic_iscn,
                "description": "Phát hiện bất thường số lượng NST",
                "confidence": 0.90
            })
            
        return suggestions
